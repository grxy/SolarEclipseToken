pragma solidity ^0.4.11;

contract Token {
    uint256 public totalSupply;
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StandardToken is Token {
    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;
}

contract SolarEclipseToken is StandardToken {
    uint8 public decimals = 18;
    string public name = '2017 Solar Eclipse Token';
    address owner;
    string public symbol = 'ECL17';

    uint startTime = 1503330410; // Aug 21, 2017 at 15:46:50 UTC
    uint endTime = 1503349461; // Aug 21, 2017 at 21:04:21 UTC

    uint metersInAU = 149597870700;
    uint milesInAU = 92955807;

    uint public totalSupplyCap = metersInAU * 1 ether;
    uint public tokensPerETH = milesInAU;

    function () payable {
        if (now < startTime) revert(); // revert if solar eclipse has not started
        if (totalSupply >= totalSupplyCap) revert(); // revert if totalSupplyCap has been exhausted

        uint tokensIssued;

        if (now > endTime) { // if token sale ended
            tokensIssued = totalSupplyCap - totalSupply;
            totalSupply = totalSupplyCap;
            balances[owner] += tokensIssued;
            Transfer(address(this), owner, tokensIssued); // transfer remaining supply to owner

            msg.sender.transfer(msg.value); // refund sender
        } else {
            owner.transfer(msg.value); // send ETH to owner

            tokensIssued = msg.value * tokensPerETH;

            if (totalSupply + tokensIssued > totalSupplyCap) {
                tokensIssued = totalSupplyCap - totalSupply; // ensure supply is capped
            }

            totalSupply += tokensIssued;
            balances[msg.sender] += tokensIssued;
            Transfer(address(this), msg.sender, tokensIssued); // transfer tokens to contributor
        }
    }

    function SolarEclipseToken() {
        owner = msg.sender;
        totalSupply = 0;
    }
}
