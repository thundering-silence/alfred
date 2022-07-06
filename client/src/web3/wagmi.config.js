import {
    WagmiConfig,
    createClient,
    configureChains,
    defaultChains,
    chain
} from 'wagmi'
import { publicProvider } from 'wagmi/providers/public'

const { chains, provider, webSocketProvider } = configureChains(
    [chain.mainnet, chain.polygon],
    [publicProvider()],
)

const client = createClient({
    autoConnect: true,
    provider,
    webSocketProvider,
})

export default client;
