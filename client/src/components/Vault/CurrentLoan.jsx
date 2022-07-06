import { useEffect, useState } from 'react'
import { useSigner } from 'wagmi'
import { constants, utils } from 'ethers'
import ActionForm from './ActionForm';
import { getAssetsBalances, vTokensV2, vTokensV3 } from './utils';

const useLoan = (vault, signer) => {
    const [loan, setLoan] = useState([]);

    const getLoan = async () => {
        const res = await getAssetsBalances(vault, signer, [...vTokensV3, ...vTokensV2])
        console.log(res)
        setLoan(res.find(item => item.amount != '0.0'))
    }

    useEffect(() => {
        getLoan()
    }, [vault, signer])

    return loan;
}

const CurrentLoan = ({ vault }) => {
    const { data: signer } = useSigner()
    const data = useLoan(vault.address, signer)
    const [showNew, setShowNew] = useState(false)

    const [amount, setAmount] = useState('')
    const [pool, setPool] = useState(import.meta.env.V_AAVE_V3_POOL);
    const [asset, setAsset] = useState(import.meta.env.V_DAI);

    const handleAmountChange = ({ target: { value } }) => {
        try {
            value && utils.parseEther(value)
            setAmount(value)
        } catch (e) {
        }
    }
    const handlePoolChange = e => setPool(e.target.value)
    const handleAssetChange = e => setAsset(e.target.value)

    const borrow = async e => {
        e.preventDefault()
        try {
            const tx = await vault.borrow(
                [
                    pool,
                    asset,
                    utils.parseEther(amount),
                ],
                {
                    gasLimit: 3000000
                }
            )
            await tx.wait()
        } catch (e) {
            console.log(e)
        }
    }

    return (<>
        <h3 className="font-bold">CURRENT LOAN</h3>
        {data?.protocol ? (
            <div className="">
                <div className="flex flex-row justify-between p-1 m-1 font-semibold">
                    <div className='flex-1'>Protocol</div>
                    <div className='flex-1'>Principal</div>
                    <div className='flex-1'>APY</div>
                    <div className='flex-1'>Health Ratio</div>
                    <p className='flex-1'>Actions</p>
                </div>
                <div className="flex flex-row justify-between p-1 m-1">
                    <div className='flex-1'>
                        {data.protocol}
                    </div>
                    <div className='flex-1'>
                        {data.symbol} {data.balance.slice(0, 10)}
                    </div>
                    <div className='flex-1'>

                    </div>
                    <div className='flex-1'>

                    </div>
                    <div className='flex-1 btn-group flex'>
                        <button
                            className="btn btn-secondary btn-sm"
                        >
                            Borrow
                        </button>
                        <button
                            className="btn btn-secondary btn-sm"
                        >
                            Repay
                        </button>
                    </div>
                </div>
            </div>)
            :
            <>
                <button
                    className="btn btn-secondary btn-sm"
                    onClick={() => setShowNew(state => !state)}
                >
                    {showNew ? 'cancel' : 'open loan'}
                </button>
                {showNew && <ActionForm
                    amount={amount}
                    handleAmountChange={handleAmountChange}
                    pool={pool}
                    handlePoolChange={handlePoolChange}
                    asset={asset}
                    handleAssetChange={handleAssetChange}
                    buttons={[
                        {
                            label: 'Borrow',
                            func: borrow
                        },
                    ]}
                />}
            </>
        }
    </>
    )
}


export default CurrentLoan;
