import { useEffect, useState } from 'react'
import { constants, utils } from 'ethers';
import { useSigner } from 'wagmi'
import ActionForm from './ActionForm';
import TableRow from './TableRow';
import { aTokensV2, aTokensV3, getAssetsBalances } from './utils';

const useSupplied = (vault, signer) => {
    const [supplied, setSupplied] = useState([]);

    const getSupplied = async () => {
        setSupplied(await getAssetsBalances(vault.address, signer, [...aTokensV3, ...aTokensV2]))
    }

    useEffect(() => {
        getSupplied()
    }, [vault, signer])

    return supplied;
}

const SuppliedAssets = ({ wMatic, vault }) => {
    const { data: signer } = useSigner()
    const supplied = useSupplied(vault, signer)
    const [newDeposit, setNewDeposit] = useState(false)
    const [amount, setAmount] = useState('')
    const [pool, setPool] = useState(import.meta.env.V_AAVE_V3_POOL);
    const [asset, setAsset] = useState(import.meta.env.V_WMATIC);

    const handleAmountChange = ({ target: { value } }) => {
        try {
            value && utils.parseEther(value) // validation
            setAmount(value)
        } catch (e) { }
    }
    const handlePoolChange = e => setPool(e.target.value)
    const handleAssetChange = e => setAsset(e.target.value)

    const approve = async e => {
        e.preventDefault()
        await wMatic.approve(vault.address, utils.parseEther(amount))
    }

    const supplyNew = async e => {
        e.preventDefault()
        console.log(pool, asset, amount)
        try {
            const tx = await vault.supply(
                [
                    pool,
                    asset,
                    utils.parseEther(amount)
                ],
                {
                    gasLimit: 3000000
                }
            )
            await tx.wait()
            setNewDeposit(false)
        } catch (e) {
            console.log(e)
        }
    }

    const supply = (pool, asset) => async e => {
        e.preventDefault()
        try {
            await vault.supply(
                [
                    pool,
                    asset,
                    utils.parseEther(amount)
                ],
                {
                    gasLimit: 3000000
                }
            )
        } catch (e) {
            console.log(e)
        }
    }

    const withdraw = (pool, asset) => async e => {
        e.preventDefault()
        try {
            await vault.withdraw(
                [
                    pool,
                    asset,
                    utils.parseEther(amount)
                ],
                {
                    gasLimit: 3000000
                }
            )
        } catch (e) {
            console.log(e)
        }
    }

    const skim = (pool, asset) => async e => {
        e.preventDefault()
        try {
            await vault.withdrawExcesses(
                [[
                    pool,
                    asset,
                    constants.Zero,
                ]],
                {
                    gasLimit: 3000000
                }
            )
        } catch (e) {
            console.log(e)
        }
    }

    const actions = row => <div className='flex'>
        <button
            className="btn btn-secondary btn-sm"
            onClick={skim(row.pool, row.underlying)}
        >
            skim
        </button>
        <form className='form-control ml-4'>
            <div className='input-group'>
                <input
                    className='input input-bordered input-sm'
                    type='text'
                    value={amount}
                    onChange={handleAmountChange}
                    placeholder={row.balance}
                />
                <button
                    className="btn btn-secondary btn-sm"
                    onClick={withdraw(row.pool, row.underlying)}
                >
                    withdraw
                </button>
            </div>
        </form>
    </div>


    return (
        <div>
            <h3 className="font-bold flex flex-row items-center">
                SUPPLIED ASSETS
                <button
                    className="btn btn-secondary btn-sm ml-4"
                    onClick={() => setNewDeposit(!newDeposit)}
                >
                    {newDeposit ? 'CANCEL' : 'Supply'}
                </button>
            </h3>
            {newDeposit && <ActionForm
                showMax={true}
                amount={amount}
                handleAmountChange={handleAmountChange}
                pool={pool}
                handlePoolChange={handlePoolChange}
                asset={asset}
                handleAssetChange={handleAssetChange}
                buttons={[
                    {
                        label: 'Approve',
                        func: approve
                    },
                    {
                        label: 'Supply',
                        func: supplyNew
                    }
                ]}
            />}
            <ul className="list-none">
                <li className="flex flex-row justify-between p-1 m-1 font-semibold">
                    <div className='flex-1'>Protocol</div>
                    <div className='flex-1'>Available</div>
                    <div className='flex-1'>Actions</div>
                </li>
                {
                    supplied.map((row, idx) => <TableRow
                        {...row}
                        key={idx}
                        actions={actions(row)}
                    />)
                }
            </ul>
        </div>
    )
}

export default SuppliedAssets;
