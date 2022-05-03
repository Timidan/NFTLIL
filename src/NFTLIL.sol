// SPDX-License-Identifier: UNLICENSED
import {ERC721Enumerable, ERC721} from "lib/openzeppelin-contracts.git/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {IWitnetRandomness} from "./IWIT.sol";
import "../lib/base64.sol";
pragma solidity 0.8.10;

contract NFTLIL is ERC721Enumerable {
    struct TokenDeets {
        string name;
        bytes32 tag;
        uint8[5] props;
    }
    mapping(uint => TokenDeets) TokenTags;


    struct Wrapper {
        string i;
        string j;
        string k;
        string l;
        string m;
    }
    uint256 tokenID = 0;
    bytes32 public randomness;
  //bytes32 latUsed;
    uint256 public latestRandomizingBlock;
    IWitnetRandomness public immutable witnet;

    constructor(IWitnetRandomness _witnetRandomness)
        payable
        ERC721("NFTLIL", "NFTL")
    {
        assert(address(_witnetRandomness) != address(0));
        witnet = _witnetRandomness;
        requestRandomness();
    }

    function requestRandomness() internal  {
        latestRandomizingBlock = block.number;
        uint _usedFunds = witnet.randomize{value: msg.value}();
        if (_usedFunds < msg.value) {
            payable(msg.sender).transfer(msg.value - _usedFunds);
        }
    }

    string[4] availNames = ["King", "Warrior", "Knight", "Steed"];

    function mintNFT() external payable {
        fetchRandomness();
        assert(randomness != 0);
        _mint(msg.sender, tokenID);
        TokenDeets storage s = TokenTags[tokenID];
        s.name = availNames[genName(randomness)];
        s.props = genProp(randomness);
        s.tag = genTag(randomness);

        tokenID++;
        requestRandomness();
    }

    function genProp(bytes32 _rand) internal returns (uint8[5] memory m) {
        uint128 base = uint128(bytes16(_rand));
        m[0] = genSingleProp(tear(_rand), 1);
        m[1] = genSingleProp(tear(_rand), 2);
        m[2] = genSingleProp(tear(_rand), 3);
        m[3] = genSingleProp(tear(_rand), 4);
        m[4] = genSingleProp(tear(_rand), 5);
    }

    function tear(bytes32 i) internal returns (uint128 torn) {
        uint256 t = uint256(bytes32(i));
        torn = uint128(t >> 128);
    }

    function genTag(bytes32 _rand) internal view returns (bytes32 b) {
        b = bytes32(_rand);
    }

    function genName(bytes32 _rand) internal view returns (uint8 pos) {
        uint128 base2 = uint128(bytes16(_rand << 128));
        uint16 mid = uint16(uint128(base2));
        pos = uint8(mid % 4);
    }

    function genSingleProp(uint128 base, uint8 offset)
        internal view
        returns (uint8 sProp_)
    {
        uint128 mid = base >> (offset & block.number);
        sProp_ = uint8(mid % 200);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        return genSvg(tokenId);
    }

    function genSvg(uint256 tokenId) internal view returns (string memory) {
        TokenDeets memory s = TokenTags[tokenId];
        assert(ownerOf(tokenId) != address(0));
        string[21] memory frags;
        Wrapper memory w = Wrapper({
            i: '</text><text x="10" y="180" class="base">',
            j: "TAG",
            k: '</text><text x="10" y="200" class="base">',
            l: toHex(s.tag),
            m: "</text></svg>"
        });
        frags[
            0
        ] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: black; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="white" /><text x="10" y="20" class="base">';
        frags[1] = "NAME";
        frags[2] = '</text><text x="10" y="40" class="base">';
        frags[3] = s.name;
        frags[4] = '</text><text x="10" y="60" class="base">';
        frags[5] = "PROPS";
        frags[6] = '</text><text x="10" y="80" class="base">';
        frags[7] = toString(s.props[0]);
        frags[8] = '</text><text x="10" y="100" class="base">';
        frags[9] = toString(s.props[1]);
        frags[10] = '</text><text x="10" y="120" class="base">';
        frags[11] = toString(s.props[2]);
        frags[12] = '</text><text x="10" y="140" class="base">';
        frags[13] = toString(s.props[3]);
        frags[14] = '</text><text x="10" y="160" class="parent">';
        frags[15] = toString(s.props[4]);
        string memory output = string(
            abi.encodePacked(
                frags[0],
                frags[1],
                frags[2],
                frags[3],
                frags[4],
                frags[5],
                frags[6],
                frags[7],
                frags[8]
            )
        );
        output = string(
            abi.encodePacked(
                output,
                frags[9],
                frags[10],
                frags[11],
                frags[12],
                frags[13],
                frags[14],
                frags[15],
                conc(w)
            )
        );
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "NFTLIL #',
                        toString(tokenId),
                        '", "description": "We were bored", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(output)),
                        '"}'
                    )
                )
            )
        );
        output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        return output;
    }

    function fetchRandomness() internal {
        assert(latestRandomizingBlock > 0);
        randomness = witnet.getRandomnessAfter(latestRandomizingBlock);
    }

    receive() external payable {}

    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT license
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHex16(bytes16 data) internal pure returns (bytes32 result) {
        result =
            (bytes32(data) &
                0xFFFFFFFFFFFFFFFF000000000000000000000000000000000000000000000000) |
            ((bytes32(data) &
                0x0000000000000000FFFFFFFFFFFFFFFF00000000000000000000000000000000) >>
                64);
        result =
            (result &
                0xFFFFFFFF000000000000000000000000FFFFFFFF000000000000000000000000) |
            ((result &
                0x00000000FFFFFFFF000000000000000000000000FFFFFFFF0000000000000000) >>
                32);
        result =
            (result &
                0xFFFF000000000000FFFF000000000000FFFF000000000000FFFF000000000000) |
            ((result &
                0x0000FFFF000000000000FFFF000000000000FFFF000000000000FFFF00000000) >>
                16);
        result =
            (result &
                0xFF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000) |
            ((result &
                0x00FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF0000) >>
                8);
        result =
            ((result &
                0xF000F000F000F000F000F000F000F000F000F000F000F000F000F000F000F000) >>
                4) |
            ((result &
                0x0F000F000F000F000F000F000F000F000F000F000F000F000F000F000F000F00) >>
                8);
        result = bytes32(
            0x3030303030303030303030303030303030303030303030303030303030303030 +
                uint256(result) +
                (((uint256(result) +
                    0x0606060606060606060606060606060606060606060606060606060606060606) >>
                    4) &
                    0x0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F) *
                7
        );
    }

    function toHex(bytes32 data) public pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "0x",
                    toHex16(bytes16(data)),
                    toHex16(bytes16(data << 128))
                )
            );
    }

    function conc(Wrapper memory c) internal view returns (bytes memory out__) {
        out__ = abi.encodePacked(c.i, c.j, c.k, c.l, c.m);
    }

    function getToken(uint256 tokenId)
        public
        view
        returns (TokenDeets memory s)
    {
        s = TokenTags[tokenId];
    }

    // function setRand(uint256 rad) public {
    //     randomness = bytes32(uint256(rad));
    // }
}
