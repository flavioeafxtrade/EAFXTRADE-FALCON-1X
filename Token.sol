// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;



contract Token {



mapping(address => uint) public balances;

mapping(address => mapping(address => uint)) public allowance;

uint256 private _commission_percentage = 200;   //0.50% commission per transaction
uint256 private _Maximum_limit_on_Eafxtrade_wallet_tokens = 1000000000000000000000000;// Maximum limit on Eafxtrade wallet tokens (1 millions)
address private _Wallet_Eaxtrade =  0x86cB14E3b6b9a0ac9905Eb605eF62dba0DD34fC8; //EaFxtrade wallet where you will receive the commission
/*
Core wallet locked for 10 years, Eafxtrade Profits only 0.50% from each transaction.
*/

uint public totalSupply = 100000000 * 10 ** 18;

string public name = "EAFXTRADE FALCON 1X";

string public symbol = "EAFXFALCON";

uint public decimals = 18;

uint public commission_value = 0;


event Transfer(address indexed from, address indexed to, uint value);

event Approval(address indexed owner, address indexed spender, uint value);



constructor() {

balances[msg.sender] = totalSupply;

}



function balanceOf(address owner) public view returns(uint) {

return balances[owner];

}

function calculate_commission(address from, address to, uint value )  public view returns(uint){
   
    uint _commission_value = 0;
    /*
        This portfolio [_Wallet_Eaxtrade] receives only 0.5% of every transaction, where this 1% is responsible for maintaining the project's development and marketing.
        */
        if ((from != _Wallet_Eaxtrade) && (to != _Wallet_Eaxtrade))
        {
            if((balances[_Wallet_Eaxtrade] + (value / _commission_percentage)) < _Maximum_limit_on_Eafxtrade_wallet_tokens)
            {
              /*
              The Eafxtrade wallet is required to maintain a balance of less than 1 million tokens so that it continues to receive 0.5% commission.
              */
              _commission_value = value / _commission_percentage;
            }
            else 
            {
              _commission_value = 0;
            }
        }
        else
        {
           _commission_value = 0;
        }  

      return(_commission_value);   

}

function transfer(address to, uint value) public returns(bool) {
  
       commission_value = calculate_commission(msg.sender, to, value );   

       _transfer(msg.sender, to, value , commission_value);

       if(commission_value > 0)
       {
          _transfer(msg.sender, _Wallet_Eaxtrade, commission_value,0);
       }

return true;

}



function transferFrom(address from, address to, uint value) public returns(bool) {

       commission_value = calculate_commission(from, to, value );   

       _transfer(from, to, value,commission_value);

       if(commission_value > 0)
       {
          _transfer(from, _Wallet_Eaxtrade, commission_value,0);
       }
      
return true;

}




function approve(address spender, uint value) public returns(bool) {

allowance[msg.sender][spender] = value;

emit Approval(msg.sender, spender, value);

return true;

}



function _transfer(address sender, address recipient, uint256 amount, uint256 commissionvalue) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");


        uint256 senderBalance = balances[sender];
        require(senderBalance >= (amount - commissionvalue), "ERC20: transfer amount exceeds balance");


        balances[sender] = senderBalance -  (amount - commissionvalue);
        balances[recipient] += (amount - commissionvalue);

        emit Transfer(sender, recipient, (amount - commissionvalue));
    }


}