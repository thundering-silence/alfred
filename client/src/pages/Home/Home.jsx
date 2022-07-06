import {Link} from 'wouter'

const Home = () => {
    return <div className="hero min-h-screen">
        <div className="hero-content text-center">
            <div className="max-w-xl">
                <h1 className="text-5xl font-bold">
                    Welcome to Alfred
                </h1>
                <h2 className="text-2xl py-6">
                    Self-repaying loans for your favourite lending markets
                </h2>
                <Link href='/vaults' className="btn btn-primary btn-lg text-base-100">
                    Get Started
                </Link>
            </div>
        </div>
    </div>
}


export default Home;
