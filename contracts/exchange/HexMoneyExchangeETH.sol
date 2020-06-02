pragma solidity ^0.6.2;

import "./HexMoneyExchangeBase.sol";
import "../UniswapGetters/IUniswapExchangeAmountGetters.sol";


contract HexMoneyExchangeETH is HexMoneyExchangeBase {

    address internal uniswapGetterInstance;


    constructor (HXY _hxyToken, address payable _dividendsContract)
    HexMoneyExchangeBase(_hxyToken, _dividendsContract)
    public {
        decimals = 10 ** 18;
        minAmount = 10 ** 10;
        maxAmount = SafeMath.mul(10 ** 9, decimals);
    }

    function getUniswapGetterInstance() public view returns (address) {
        return uniswapGetterInstance;
    }

    function setUniswapGetterInstance(address newUniswapGetterInstance)  public onlyAdminRole {
        uniswapGetterInstance = newUniswapGetterInstance;
    }

    function getConvertedAmount(uint256 _amount) public view returns (uint256) {
        return IUniswapExchangeAmountGetters(uniswapGetterInstance).getEthToTokenInputPrice(_amount);
    }

        // Assets Transfers
    receive() external payable {
        uint256 hexAmount = IUniswapExchangeAmountGetters(uniswapGetterInstance).getEthToTokenInputPrice(msg.value);

        HXY(hxyToken).mintFromDapp(_msgSender(), hexAmount);
        _addToDividends(msg.value);
    }

    function exchangeEth() public payable {
        uint256 hexAmount = IUniswapExchangeAmountGetters(uniswapGetterInstance).getEthToTokenInputPrice(msg.value);

        HXY(hxyToken).mintFromDapp(_msgSender(), hexAmount);
        _addToDividends(msg.value);
    }

    function _addToDividends(uint256 _amount) internal override {
        dividendsContract.transfer(_amount);
    }


}