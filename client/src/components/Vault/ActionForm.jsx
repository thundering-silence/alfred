import { utils } from 'ethers'
import { useEffect, useState } from 'react'
import { useContract, useSigner } from 'wagmi'

const ActionForm = ({
    amount,
    handleAmountChange,
    pool,
    handlePoolChange,
    asset,
    handleAssetChange,
    buttons,
    showMax
}) => {
    const { data: signer } = useSigner()
    const token = useContract({
        addressOrName: asset,
        contractInterface: ["function balanceOf(address) public view returns (uint)"],
        signerOrProvider: signer
    })
    const [max, setMax] = useState()
    const fetchBalance = async token => {
        const res = await token.balanceOf(await signer.getAddress())
        setMax(utils.formatEther(res))
    }

    useEffect(() => {
        fetchBalance(token)
    }, [token])
    return (
        <form className="flex flex-row justify-between items-end p-1 m-1">
            <div className='form-control flex-1'>
                <label className='label'>Protocol</label>
                <select
                    className="select select-bordered w-full max-w-xs select-sm"
                    value={pool}
                    onChange={handlePoolChange}
                >
                    <option value={import.meta.env.V_AAVE_V2_POOL}>Aave V2</option>
                    <option value={import.meta.env.V_AAVE_V3_POOL}>Aave V3</option>
                </select>
            </div>

            <div className='form-control flex-1'>
                <label className='label'>Asset</label>
                <select
                    className="flex-1 select select-bordered w-full max-w-xs select-sm"
                    value={asset}
                    onChange={handleAssetChange}
                >
                    <option value={import.meta.env.V_WMATIC}>Wrapped MATIC</option>
                    <option value={import.meta.env.V_DAI}>DAI</option>
                </select>
            </div>

            <div className='form-control flex-1'>
                <label className='label'>
                    <span className='label-text'>Amount</span>
                    {showMax && <span className='label-text-alt'>MAX: {max}</span>}
                </label>
                <input
                    type="text"
                    className='input input-bordered w-full max-w-xs input-sm'
                    placeholder='0.00'
                    value={amount}
                    onChange={handleAmountChange}
                />
            </div>

            <div className='flex-1 btn-group justify-center'>
                {buttons.map(({ label, func }) => <button
                    className="btn btn-secondary btn-sm"
                    onClick={func}
                    key={label}
                >
                    {label}
                </button>
                )}
            </div>
        </form >
    )
}


export default ActionForm
