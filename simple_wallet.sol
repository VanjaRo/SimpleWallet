pragma solidity >=0.5.0 <0.6.0;

import "./ownable.sol";
import "./IERC20.sol";

contract SimpleWallet is Ownable {
    uint256 public fee = 0;
    address public feeOwner = 0x...;

    event ReceiveETH(address _from, uint256 _amount);
    event TransferETH(address _from, address _to, uint256 _amount);
    event TransferERC20(address _from, address _to, uint256 _amount);
    event AllowanceERC20Changed(address owner, uint256 _amount);
    event FeeETHChanged(address owner, uint256 _amount);

    // Modifier for feeOwner to be able to set up the fee
    modifier onlyFeeOwner() {
        require(msg.sender == feeOwner);
        _;
    }

    function balance() public view returns (uint256) {
        return address(this).balance();
    }

    // Operations with ETH
    // Receive
    function() external payable {
        emit ReceiveETH(msg.sender, msg.value);
    }

    // Transfer to
    function transferETH(uint256 _amount, address payable _to)
        public
        onlyOwner
        returns (bool)
    {
        require(_amount + fee <= balance());

        (bool success, ) = _to.transfer(_amount);
        if (success) {
            feeOwner.transfer(fee);
            emit TransferETH(msg.sender, _to, _amount);
        }
        return success;
    }

    // Additional Fee
    // Getting Fee
    function feeETHGet() external view returns (uint256) {
        return fee;
    }

    // Setting the fee for the ETH transaction
    function feeETHSet(uint256 _amount) external onlyFeeOwner {
        fee = _amount;
        emit FeeETHChanged(msg.sender, _amount);
    }

    // Operations with ERC20 tokens
    // Transfer to
    function transferERC20(
        IERC20 _token,
        uint256 _amount,
        address payable _to
    ) public onllyOwner returns (bool) {
        uint256 erc20Balance = _token.balanceOf(address(this));
        require(_amount <= erc20Balance);

        bool success = token.transferFrom(msg.sender, _to, _amount);
        if (success) {
            emit TransferERC20(msg.sender, _to, _amount);
        }
        return success;
    }

    // Receiving the allowence amount of the wallet owner
    function allowanceERC20Get(IERC20 _token)
        external
        view
        onlyOwner
        returns (uint256)
    {
        return _token.allowance(msg.sender, msg.sender);
    }

    // Setting the allowance amount
    function allowanceERC20Set(IERC20 _token, uint256 _amount)
        external
        onlyOwner
        returns (bool)
    {
        bool success = _token.approve(msg.sender, _amount);
        if (success) {
            emit FeeETHChanged(msg.sender, _amount);
        }
        return success;
    }
}
