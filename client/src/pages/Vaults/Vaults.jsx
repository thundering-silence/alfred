import { useEffect, useState } from 'react'
import { useAccount, useBalance, useContract, useSigner } from 'wagmi'
import { constants, utils } from 'ethers'
import { Clear } from 'styled-icons/material'
import Vault from '../../components/Vault/Vault'
import VaultGenerator from '../../contracts/VaultGenerator.sol/VaultGenerator.json'



const Vaults = () => {
    const [showNew, setShowNew] = useState(false)
    const [name, setName] = useState('')
    const [wrapAmount, setWrapAmount] = useState('')
    const [vaults, setVaults] = useState([])
    const { data: signer } = useSigner()
    const { address } = useAccount()
    const { data: { formatted } } = useBalance({
        addressOrName: address
    })

    const generator = useContract({
        addressOrName: import.meta.env.V_VAULT_GENERATOR,
        contractInterface: VaultGenerator.abi,
        signerOrProvider: signer
    })

    const WMATIC = useContract({
        addressOrName: import.meta.env.V_WMATIC,
        contractInterface: [
            "function deposit(uint amt) public payable"
        ],
        signerOrProvider: signer
    })

    const handleWrapAmountChange = ({ target: { value } }) => {
        try {
            value && utils.parseEther(value) // validate
            setWrapAmount(value)
        } catch (e) { }
    }

    const fetchVaults = async () => {
        const res = await generator.getAccountVaults(address);
        setVaults(res)
    }

    useEffect(() => {
        fetchVaults()
    }, [address, generator])

    const wrapMatic = async e => {
        e.preventDefault()
        const amt = utils.parseEther(wrapAmount)
        const tx = await WMATIC.deposit(amt, { value: amt })
    }

    const createNewVault = async (e) => {
        e.preventDefault()
        const tx = await generator.createVault(name)
        const receipt = await tx.wait()
        console.log(receipt)
        setName('')
        setShowNew(false)
        fetchVaults()
    }

    return <div className="min-h-screen text-center bg-neutral">
        <h1 className='text-4xl py-9 font-semibold'>Vaults</h1>

        <div className='container container-xl mx-auto'>
            <div
                className="flex flex-row justify-between align-center"
            >
                {!showNew && <button
                    className="btn btn-primary text-base-100"
                    onClick={() => setShowNew(true)}
                >
                    Create new
                </button>}
                <form className='form-control flex flex-row'>

                    <input placeholder={`${formatted} MAX`} className='input input-bordered' type='text' value={wrapAmount} onChange={handleWrapAmountChange} />

                    <button onClick={wrapMatic} className="btn btn-outline">wrap</button>
                </form>
            </div>

            {showNew && <div className="flex justify-center">
                <form className="card bg-base-100 p-4 form-control w-full max-w-md shadow-md">
                    <label className="label">
                        <span className="label-text">Vault Name</span>
                    </label>
                    <input
                        type="text"
                        placeholder="Type here..."
                        className="input input-bordered w-full max-w-s"
                        value={name}
                        onChange={e => setName(e.target.value)}
                    />
                    <label className="label">
                        <span className="label-text-alt">Choose a name for the vault</span>
                        <span className="label-text-alt">{name.length}/20</span>
                    </label>
                    <div className="flex justify-around">

                        <button
                            className="btn btn-neutral btn-outline max-w-5"
                            onClick={() => setShowNew(false)}
                        >
                            Cancel
                        </button>
                        <button
                            className="btn btn-primary max-w-5 text-base-100"
                            type="submit"
                            onClick={createNewVault}
                            disabled={!name || name.length > 20}
                        >
                            Confirm
                        </button>
                    </div>
                </form>
            </div>
            }
            {vaults?.map(el => <Vault address={el} signer={signer} key={el.address} fetchVaults={fetchVaults} />)}
        </div>
    </div>
}


export default Vaults;
