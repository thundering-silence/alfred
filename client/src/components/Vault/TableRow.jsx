
const TableRow = ({ protocol, symbol, balance, actions }) => {

    return (
        <li
            className="flex flex-row justify-between p-1 m-1"
        >
            <div className='flex-1'>{protocol}</div>
            <div className='flex-1'>{symbol} {balance.slice(0, 10)}</div>
            <div className='flex-1'>
                {actions}
            </div>
        </li>
    )
}

export default TableRow;
