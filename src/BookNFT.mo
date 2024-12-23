import _Debug "mo:base/Debug";
import Hash "mo:base/Hash";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Array "mo:base/Array";
import Option "mo:base/Option";
import Iter "mo:base/Iter";
import Error "mo:base/Error";

actor {
    // Book structure
    public type Book = {
        id : Nat;
        name : Text;
        author : Text;
        authorAddress : Principal;
        totalSupply : Nat;
        price : Nat;
        initialRoyalty : Nat;
        resaleRoyalty : Nat;
        transactionCount : Nat;
    };

    // NFT Ownership structure
    public type NFTOwnership = {
        bookId : Nat;
        owner : Principal;
        resalePrice : ?Nat;
    };

    // State variables
    private stable var bookIds : [Nat] = [];
    private let books = HashMap.HashMap<Nat, Book>(
        10,
        Nat.equal,
        func(n : Nat) : Hash.Hash {
            // Custom hash function that considers all bits
            let x = Nat32.fromNat(n);
            let h1 = x * 0x9E3779B1;
            let h2 = h1 ^ (h1 >> 16);
            h2;
        },
    );
    private let nftOwnerships = HashMap.HashMap<Nat, NFTOwnership>(
        10,
        Nat.equal,
        func(n : Nat) : Hash.Hash {
            // Custom hash function that considers all bits
            let x = Nat32.fromNat(n);
            let h1 = x * 0x9E3779B1;
            let h2 = h1 ^ (h1 >> 16);
            h2;
        },
    );
    private let bookOwners = HashMap.HashMap<Nat, [Principal]>(
        10,
        Nat.equal,
        func(n : Nat) : Hash.Hash {
            // Custom hash function that considers all bits
            let x = Nat32.fromNat(n);
            let h1 = x * 0x9E3779B1;
            let h2 = h1 ^ (h1 >> 16);
            h2;
        },
    );
    private stable var tokenCounter : Nat = 0;

    // Events (simulated through public functions)
    public type BookCreatedEvent = {
        id : Nat;
        name : Text;
        author : Text;
        authorAddress : Principal;
        totalSupply : Nat;
        price : Nat;
        initialRoyalty : Nat;
        resaleRoyalty : Nat;
    };

    // Create a new book
    public shared (msg_) func createBook(
        bookId : Nat,
        name : Text,
        author : Text,
        authorAddress : Principal,
        totalSupply : Nat,
        price : Nat,
        initialRoyalty : Nat,
        resaleRoyalty : Nat,
    ) : async BookCreatedEvent {
        // Validate inputs
        if (Option.isSome(books.get(bookId))) {
            throw Error.reject("Book ID already exists");
        };

        if (initialRoyalty > 100 or resaleRoyalty > 100) {
            throw Error.reject("Royalties must be between 0 and 100");
        };

        // Create new book
        let newBook : Book = {
            id = bookId;
            name = name;
            author = author;
            authorAddress = authorAddress;
            totalSupply = totalSupply;
            price = price;
            initialRoyalty = initialRoyalty;
            resaleRoyalty = resaleRoyalty;
            transactionCount = 0;
        };

        // Store book
        books.put(bookId, newBook);
        bookOwners.put(bookId, []);

        // Update book IDs
        let updatedBookIds = Array.append(bookIds, [bookId]);
        bookIds := updatedBookIds;

        // Return event-like data
        {
            id = bookId;
            name = name;
            author = author;
            authorAddress = authorAddress;
            totalSupply = totalSupply;
            price = price;
            initialRoyalty = initialRoyalty;
            resaleRoyalty = resaleRoyalty;
        };
    };

    // Buy NFT
    public shared (msg_) func buyNFT(bookId : Nat) : async NFTOwnership {
        // Retrieve book
        let book = switch (books.get(bookId)) {
            case null { throw Error.reject("Book not found") };
            case (?existingBook) { existingBook };
        };

        // Validate purchase conditions
        if (book.totalSupply == 0) {
            throw Error.reject("No supply available");
        };

        // Generate token ID
        let tokenId = tokenCounter + bookId;
        tokenCounter += 1;

        // Create NFT ownership
        let nftOwnership : NFTOwnership = {
            bookId = bookId;
            owner = msg_.caller;
            resalePrice = null;
        };

        // Update book details
        let updatedBook : Book = {
            id = book.id;
            name = book.name;
            author = book.author;
            authorAddress = book.authorAddress;
            totalSupply = book.totalSupply - 1;
            price = book.price;
            initialRoyalty = book.initialRoyalty;
            resaleRoyalty = book.resaleRoyalty;
            transactionCount = book.transactionCount + 1;
        };

        // Store updated book and ownership
        books.put(bookId, updatedBook);
        nftOwnerships.put(tokenId, nftOwnership);

        // Update book owners
        let currentOwners = switch (bookOwners.get(bookId)) {
            case null { [] };
            case (?owners) { owners };
        };

        if (not _principalInArray(currentOwners, msg_.caller)) {
            bookOwners.put(bookId, Array.append(currentOwners, [msg_.caller]));
        };

        nftOwnership;
    };

    // Set resale price
    public shared (msg_) func setResalePrice(bookId : Nat, price : Nat) : async NFTOwnership {
        // Find NFT ownership
        let nft = switch (nftOwnerships.get(bookId)) {
            case null { throw Error.reject("NFT not found") };
            case (?existingNFT) { existingNFT };
        };

        // Validate ownership
        if (nft.owner != msg_.caller) {
            throw Error.reject("Not the owner of this NFT");
        };

        // Update resale price
        let updatedNFT : NFTOwnership = {
            bookId = nft.bookId;
            owner = nft.owner;
            resalePrice = ?price;
        };

        nftOwnerships.put(bookId, updatedNFT);
        updatedNFT;
    };

    // Transfer NFT
    public shared (msg_) func transferNFT(bookId : Nat, to : Principal) : async NFTOwnership {
        // Find NFT ownership
        let nft = switch (nftOwnerships.get(bookId)) {
            case null { throw Error.reject("NFT not found") };
            case (?existingNFT) { existingNFT };
        };

        // Validate ownership
        if (nft.owner != msg_.caller) {
            throw Error.reject("Not the owner of this NFT");
        };

        // Update NFT ownership
        let updatedNFT : NFTOwnership = {
            bookId = nft.bookId;
            owner = to;
            resalePrice = null;
        };

        nftOwnerships.put(bookId, updatedNFT);

        // Update book owners
        let currentOwners = switch (bookOwners.get(bookId)) {
            case null { [] };
            case (?owners) { owners };
        };

        if (not _principalInArray(currentOwners, to)) {
            bookOwners.put(bookId, Array.append(currentOwners, [to]));
        };

        updatedNFT;
    };

    // Helper function to check if a Principal is in an array
    private func _principalInArray(arr : [Principal], p : Principal) : Bool {
        for (x in arr.vals()) {
            if (x == p) return true;
        };
        false;
    };

    // Query functions
    public query func getAllBooks() : async [Book] {
        Iter.toArray(books.vals());
    };

    public query func getBook(bookId : Nat) : async ?Book {
        books.get(bookId);
    };

    public query func getNFTPurchaseInfo(bookId : Nat) : async ?(Nat, Nat) {
        switch (books.get(bookId)) {
            case null { null };
            case (?book) {
                ?(book.transactionCount, book.totalSupply + book.transactionCount);
            };
        };
    };

    public query func getUniqueOwners(bookId : Nat) : async Nat {
        switch (bookOwners.get(bookId)) {
            case null { 0 };
            case (?owners) { owners.size() };
        };
    };

    // Resale functions
    public shared (msg_) func buyResaleNFT(bookId : Nat, owner : Principal) : async NFTOwnership {
        // Find NFT ownership
        let nft = switch (nftOwnerships.get(bookId)) {
            case null { throw Error.reject("NFT not found") };
            case (?existingNFT) { existingNFT };
        };

        // Check resale price
        let resalePrice = switch (nft.resalePrice) {
            case null { throw Error.reject("This NFT is not for sale") };
            case (?price) { price };
        };

        // Validate ownership
        if (nft.owner != owner) {
            throw Error.reject("Invalid owner for this NFT");
        };

        // Update NFT ownership
        let updatedNFT : NFTOwnership = {
            bookId = nft.bookId;
            owner = msg_.caller;
            resalePrice = null;
        };

        nftOwnerships.put(bookId, updatedNFT);

        // Update book owners
        let currentOwners = switch (bookOwners.get(bookId)) {
            case null { [] };
            case (?owners) { owners };
        };

        if (not _principalInArray(currentOwners, msg_.caller)) {
            bookOwners.put(bookId, Array.append(currentOwners, [msg_.caller]));
        };

        // Update book transaction count
        let book = switch (books.get(bookId)) {
            case null { throw Error.reject("Book not found") };
            case (?existingBook) { existingBook };
        };

        let updatedBook : Book = {
            id = book.id;
            name = book.name;
            author = book.author;
            authorAddress = book.authorAddress;
            totalSupply = book.totalSupply;
            price = book.price;
            initialRoyalty = book.initialRoyalty;
            resaleRoyalty = book.resaleRoyalty;
            transactionCount = book.transactionCount + 1;
        };

        books.put(bookId, updatedBook);

        updatedNFT;
    };

    // Cancel resale price
    public shared (msg_) func cancelResalePrice(bookId : Nat) : async NFTOwnership {
        // Find NFT ownership
        let nft = switch (nftOwnerships.get(bookId)) {
            case null { throw Error.reject("NFT not found") };
            case (?existingNFT) { existingNFT };
        };

        // Validate ownership
        if (nft.owner != msg_.caller) {
            throw Error.reject("Not the owner of this NFT");
        };

        // Update NFT ownership
        let updatedNFT : NFTOwnership = {
            bookId = nft.bookId;
            owner = nft.owner;
            resalePrice = null;
        };

        nftOwnerships.put(bookId, updatedNFT);
        updatedNFT;
    };
};
