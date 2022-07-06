
import { useEffect, useState } from 'react'
import { useContract } from 'wagmi';

import VaultContract from '../../contracts/Vault.sol/Vault.json'
import CurrentLoan from './CurrentLoan';
import VaultHeader from './Header';
import SuppliedAssets from './SuppliedAssets';




const Vault = ({ address, signer, fecthVaults }) => {
    const [name, setName] = useState()

    const vault = useContract({
        addressOrName: address,
        contractInterface: VaultContract.abi,
        signerOrProvider: signer
    })

    const WMATIC = useContract({
        addressOrName: import.meta.env.V_WMATIC,
        contractInterface: [
            "function approve(address dst,uint amt) public"
        ],
        signerOrProvider: signer
    })

    const getName = async () => setName(await vault.name())

    useEffect(() => {
        getName()
    }, [vault])

    const requestSwaps = async () => {
        const tx = await vault.requestSwaps([import.meta.env.V_WMATIC])
        await tx.wait()
        fecthVaults()
    }


    return (
        <div className="card bg-base-100 shadow-md collapse my-4">
            <VaultHeader name={name} address={address} />
            <div className="collapse-content text-start bg-info">
                <div className="p-2">
                    <button className="btn btn-primary" onClick={requestSwaps}>do swaps</button>
                    <CurrentLoan vault={vault} />
                    <div className="divider mt-0 mb-0" />
                    <SuppliedAssets wMatic={WMATIC} vault={vault} />
                </div>
            </div>
        </div>
    )
}

export default Vault;
