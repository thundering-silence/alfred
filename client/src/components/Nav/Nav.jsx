import { Link, useLocation } from 'wouter'
import { useAccount, useConnect } from 'wagmi'
import { InjectedConnector } from 'wagmi/connectors/injected'

import { Menu } from '@styled-icons/entypo'

const NavLinks = () => {
    const [location, setLocation] = useLocation()
    return <>
        <Link
            href='/'
            className={`link text-xl px-3 ${location === '/' && 'link link-accent'}`}
        >
            Home
        </Link>
        <Link
            href='/vaults'
            className={`link text-xl px-3 ${location === '/vaults' && 'link link-accent'}`}
        >
            My Vaults
        </Link>
    </>
}


const Nav = () => {
    const { address, isConnected } = useAccount()

    const { connect } = useConnect({
        connector: new InjectedConnector(),
    })

    return (
        <nav className="navbar  bg-base-100 drop-shadow-md rounded-2xl">
            <div className="navbar-start">
                <div className="dropdown">
                    <label tabIndex="0" className="btn btn-ghost lg:hidden">
                        <Menu size={32} />
                    </label>
                    <ul tabIndex="0" className="menu menu-compact dropdown-content mt-3 p-2 shadow bg-base-100 rounded-box w-52">
                        <NavLinks />
                    </ul>
                </div>
                <a className="normal-case font-bold text-2xl px-4">Alfred</a>
            </div>
            <div className="navbar-center hidden lg:flex">
                <NavLinks />
            </div>
            <div className="navbar-end">
                {isConnected ?
                    <button
                        className='btn btn-primary btn-outline hidden md:flex'
                    >
                        {address}
                    </button> :
                    <button
                        className="btn btn-secondary"
                        onClick={connect}
                    >
                        Connect Wallet
                    </button>
                }
            </div>
        </nav>
    )
}

export default Nav;
