pragma solidity ^0.4.11;

contract IVotingToken {
    function balanceOf(address _owner) constant returns (uint256 balance); 
}

contract VoteSession {
    bytes32[] _questionIds;
    mapping(bytes32 => uint) _questionTextRows;
    mapping(bytes32 => mapping(uint => bytes32)) _questionText;
    mapping(bytes32 => bytes32) _boardRecommendation;
    mapping(bytes32 => uint) _questionIsActive;
    mapping(bytes32 => uint) _hasQuestion;


    address _owner;
    address _voteToken;

    mapping(address => bytes32) _voteSelections;
    mapping(address => bytes32) _voteSessionIds;
    mapping(address => bytes32) _voteTransactionIds;
    mapping(address => uint) _blockNumbers;
    mapping(address => uint) _hasVoted;
    address[] _voteSelectionsAddresses;

    function VoteSession() {
        _owner = msg.sender;
    }

    function setVoteTokenAddress(address voteToken) returns (bool setTokenId){
        require(msg.sender==_owner);
        
        _voteToken = voteToken;

        return true;
    }



    function getVoteTokenAddress() returns (address VoteToken) {  
        return (_voteToken);
    }

    function vote(string voteSessionId, string selectedAnswers) returns (bool Result) {        
        if (_hasVoted[msg.sender] == 0) {
            _hasVoted[msg.sender] = 1;
            _voteSelectionsAddresses.push(msg.sender);
        }

        _voteSessionIds[msg.sender] = stringToBytes32(voteSessionId);
        _voteTransactionIds[msg.sender] = stringToBytes32("");
        _voteSelections[msg.sender] = stringToBytes32(selectedAnswers);
        _blockNumbers[msg.sender] = block.number;

        return true;
    }

    function setVoteTransactionId(address votedAddress, string voteSessionId, string transactionId) returns (bool Result) {        
        require(_voteSessionIds[votedAddress] == stringToBytes32(voteSessionId)); 
        
        if (_voteSessionIds[votedAddress] == stringToBytes32(voteSessionId)) {
            _voteTransactionIds[votedAddress] = stringToBytes32(transactionId);
        } 
       
        return true;
    }

    function getLastVoteSessionId() returns (string voteSessionId1) {
        string memory voteSessionId;

        if (_hasVoted[msg.sender] == 0) {
            voteSessionId = "";            
        } else {
            voteSessionId = bytes32ToString(_voteSessionIds[msg.sender]);
        }

        return voteSessionId;
    }

    function totalVoters() returns (uint256 totalVoters) {
        return _voteSelectionsAddresses.length;
    }

    function getVoteAnswers() returns (uint256 indexVoter1,address voter, string voteSessionId, string voteAnswers, uint blockNumber, uint256 balance) {
        return (getVoteAnswersByAddress(0,msg.sender));
    }

    function getVoteAnswersByIndex(uint256 voterIndex) returns (uint256 indexVoter1,address voter, string voteSessionId, string voteAnswers, uint blockNumber, uint256 balance) {
        address selectedAddress = _voteSelectionsAddresses[voterIndex];
        return (getVoteAnswersByAddress(voterIndex,selectedAddress));
    }

    function getVoteAnswersByAddress(uint256 indexVoter,address voterAddress) returns (uint256 indexVoter1,address voter, string voteSessionId, string voteAnswers, uint blockNumber, uint256 balance) {
        IVotingToken votingToken = IVotingToken(_voteToken);

        return (indexVoter, voterAddress, bytes32ToString(_voteSessionIds[voterAddress]), bytes32ToString(_voteSelections[voterAddress]), _blockNumbers[voterAddress],votingToken.balanceOf(voterAddress));
    }

    function insertUpdateQuestion(string questionId, uint questionTextRows, bytes32 questionText, string boardRecommendation, uint isActive) returns (bool insertupdate) {
        bytes32 bytesQuestionId = stringToBytes32(questionId);
        if (_hasQuestion[bytesQuestionId] == 0) {
            _hasQuestion[bytesQuestionId] = 1;
            _questionIds.push(bytesQuestionId);
        }

        _questionTextRows[bytesQuestionId] = questionTextRows;
        _boardRecommendation[bytesQuestionId] = stringToBytes32(boardRecommendation);
        _questionIsActive[bytesQuestionId] = isActive;
        _questionText[bytesQuestionId][0] = questionText;
    }
    function addQuestionTextRow(string questionId, uint questionTextRow, bytes32 questionText) returns (bool success) {
        bytes32 bytesQuestionId = stringToBytes32(questionId);
        _questionText[bytesQuestionId][questionTextRow] = questionText;

        return true;
    } 

    function getQuestionTextByRow(string questionId, uint questionTextRow) returns (string questionid, uint row, bytes32 textLine) {
        bytes32 bytesQuestionId = stringToBytes32(questionId);
        return (questionId, questionTextRow,_questionText[bytesQuestionId][questionTextRow]);
    }

    function totalQuestions() returns (uint totalQuestions) {
        return _questionIds.length;
    }

    function getQuestionByIndex(uint questionIndex) returns (uint questionIndex1, string questionId, uint questionTextRows, string boardRecommendation,uint isActive) {
        bytes32 bytesQuestionId = _questionIds[questionIndex];
        return (questionIndex, bytes32ToString(_questionIds[questionIndex]),_questionTextRows[bytesQuestionId],bytes32ToString(_boardRecommendation[bytesQuestionId]),_questionIsActive[bytesQuestionId]);
    }

    function stringToBytes32(string memory source) returns (bytes32 result) {
        assembly {
            result := mload(add(source, 32))
        }
    }

    function bytes32ToString(bytes32 x) constant returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }

}