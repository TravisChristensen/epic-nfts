// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

// We first import some OpenZeppelin Contracts.
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

import {Base64} from "./libraries/Base64.sol";

// We inherit the contract we imported. This means we'll have access
// to the inherited contract's methods.
contract MyEpicNFT is ERC721URIStorage {
    // Magic given to us by OpenZeppelin to help us keep track of tokenIds.
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string svgOpen =
        "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'>";
    string svgStyle =
        "<style>.base { fill: white;font-family: sans-serif; font-size: 14px; } </style>";
    string svgBackground =
        "<rect width='100%' height='100%' fill='url(#Gradient1)' />";
    string svgTextOpen =
        "<text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";
    string svgTextClose = "</text>";
    string svgClose = "</svg>";

    string[] firstNames = [
        "Regulus",
        "Sirius",
        "Lavender",
        "Cho",
        "Vincent",
        "Bartemius",
        "Fleur",
        "Cedric",
        "Alberforth",
        "Albus",
        "Dudley",
        "Petunia",
        "Vernon",
        "Argus",
        "Seamus",
        "Nicolas",
        "Cornelius",
        "Goyle",
        "Gregory",
        "Hermione",
        "Rubeus",
        "Igor",
        "Viktor",
        "Bellatrix",
        "Alice",
        "Frank",
        "Neville",
        "Luna",
        "Xenophilius",
        "Remus",
        "Draco",
        "Lucius",
        "Narcissa",
        "Olympe",
        "Minerva",
        "Alastor",
        "Peter",
        "Harry",
        "James",
        "Lily",
        "Quirinus",
        "Tom",
        "Mary",
        "Lord",
        "Rita",
        "Severus",
        "Nymphadora",
        "Dolores",
        "Arthur",
        "Bill",
        "Charlie",
        "Fred",
        "George",
        "Ginny",
        "Molly",
        "Percy",
        "Ron"
    ];
    string[] secondNames = [
        "Black",
        "Brown",
        "Chang",
        "Crabbe",
        "Crouch",
        "Delacour",
        "Diggory",
        "Dumbledore",
        "Dursley",
        "Filch",
        "Finnigan",
        "Flamel",
        "Fudge",
        "Goyle",
        "Granger",
        "Hagrid",
        "Karkaroff",
        "Krum",
        "Lestrange",
        "Longbottom",
        "Lovegood",
        "Lupin",
        "Malfoy",
        "Maxime",
        "McGonagall",
        "Moody",
        "Pettigrew",
        "Potter",
        "Quirrell",
        "Riddle",
        "Voldemort",
        "Skeeter",
        "Snape",
        "Tonks",
        "Umbridge",
        "Weasley"
    ];
    string[] houses = ["Gryffindor", "Hufflepuff", "Ravenclaw", "Slytherin"];

    event NewEpicNFTMinted(address sender, uint256 tokenId);
    event CurrentTokenId(uint256 tokenId);

    // We need to pass the name of our NFTs token and it's symbol.
    constructor() ERC721("WizardNFT", "WIZARD") {
        console.log("This is my NFT contract. Woah!");
    }

    function random(string memory input) private pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    // I create a function to randomly pick a word from each array.
    function pickRandomFirstName() private view returns (string memory) {
        uint256 rand = random(
            string(
                abi.encodePacked(
                    "FIRST_NAME",
                    Strings.toString(block.timestamp)
                )
            )
        );
        // Squash the # between 0 and the length of the array to avoid going out of bounds.
        rand = rand % firstNames.length;
        return firstNames[rand];
    }

    function pickRandomSecondName() private view returns (string memory) {
        uint256 rand = random(
            string(
                abi.encodePacked(
                    "SECOND_NAME",
                    Strings.toString(block.timestamp)
                )
            )
        );
        rand = rand % secondNames.length;
        return secondNames[rand];
    }

    function pickRandomHouse() private view returns (string memory) {
        uint256 rand = random(
            string(abi.encodePacked("HOUSE", Strings.toString(block.timestamp)))
        );
        rand = rand % houses.length;
        return houses[rand];
    }

    //ty stack overflow :)
    function uint8ToHexChar(uint8 i) private pure returns (uint8) {
        return
            (i > 9)
                ? (i + 87) // ascii a-f
                : (i + 48); // ascii 0-9
    }

    function uint24ToHexStr(uint24 i) private pure returns (string memory) {
        bytes memory o = new bytes(6);
        uint24 mask = 0x00000f; // hex 15
        uint256 k = 6;
        do {
            k--;
            o[k] = bytes1(uint8ToHexChar(uint8(i & mask)));
            i >>= 4;
        } while (k > 0);
        return string(o);
    }

    function generateColorHex(string memory seed)
        private
        view
        returns (string memory)
    {
        uint24 rand = uint24(
            random(
                string(
                    abi.encodePacked(
                        "COLOR",
                        seed,
                        Strings.toString(block.timestamp)
                    )
                )
            )
        );

        return string(abi.encodePacked("#", uint24ToHexStr(rand)));
    }

    function generateSvgGradient() private view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "<defs><linearGradient id='Gradient1' x1='0' x2='0' y1='0' y2='1'>",
                    "<stop offset='0%' stop-color='",
                    generateColorHex("A"),
                    "' />",
                    "<stop offset='50%' stop-color='black' />",
                    "<stop offset='100%' stop-color='",
                    generateColorHex("B"),
                    "' />",
                    "</linearGradient></defs>"
                )
            );
    }

    function generateRandomWizard() private view returns (string memory) {
        string memory firstName = pickRandomFirstName();
        string memory secondName = pickRandomSecondName();
        string memory house = pickRandomHouse();
        return
            string(abi.encodePacked(firstName, " ", secondName, " of ", house));
    }

    function generateSvgNameText(string memory name)
        private
        view
        returns (string memory)
    {
        return string(abi.encodePacked(svgTextOpen, name, svgTextClose));
    }

    function generateSvg(string memory name)
        private
        view
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    svgOpen,
                    generateSvgGradient(),
                    svgStyle,
                    svgBackground,
                    generateSvgNameText(name),
                    svgClose
                )
            );
    }

    function getMintCount() public view returns (uint256) {
        return _tokenIds.current();
    }

    // A function our user will hit to get their NFT.
    function makeAnEpicNFT() public {
        string memory name = generateRandomWizard();
        string memory finalSvg = generateSvg(name);

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        name,
                        '", "description": "',
                        name,
                        ' is a wonderfully wacky wizard!", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log("\n--------------------");
        console.log(finalTokenUri);
        console.log("--------------------\n");

        // Get the current tokenId, this starts at 0.
        uint256 newItemId = _tokenIds.current();

        // Actually mint the NFT to the sender using msg.sender.
        _safeMint(msg.sender, newItemId);

        // Set the NFTs data.
        _setTokenURI(newItemId, finalTokenUri);

        console.log(
            "An NFT w/ ID %s has been minted to %s",
            newItemId,
            msg.sender
        );

        // Increment the counter for when the next NFT is minted.
        _tokenIds.increment();

        emit NewEpicNFTMinted(msg.sender, newItemId);
        emit CurrentTokenId(_tokenIds.current());
    }
}
