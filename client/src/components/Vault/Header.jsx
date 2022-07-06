

const VaultHeader = ({ name, address }) => {
    return (
        <>
            <input type="checkbox" className="peer" />
            <div className="card-body items-center text-center flex flex-row justify-between collapse-title">
                <div>
                    <h2 className="card-title">
                        {name}
                    </h2>
                    <p className="text-sm">
                        {address}
                    </p>
                </div>
                <div className="card-actions">
                    <button className="btn btn-secondary btn-outline">MORE</button>
                </div>
            </div>
        </>
    )
}

export default VaultHeader;
