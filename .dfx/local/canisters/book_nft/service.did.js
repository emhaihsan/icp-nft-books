export const idlFactory = ({ IDL }) => {
  const NFTOwnership = IDL.Record({
    'owner' : IDL.Principal,
    'bookId' : IDL.Nat,
    'resalePrice' : IDL.Opt(IDL.Nat),
  });
  const BookCreatedEvent = IDL.Record({
    'id' : IDL.Nat,
    'name' : IDL.Text,
    'authorAddress' : IDL.Principal,
    'totalSupply' : IDL.Nat,
    'author' : IDL.Text,
    'initialRoyalty' : IDL.Nat,
    'price' : IDL.Nat,
    'resaleRoyalty' : IDL.Nat,
  });
  const Book = IDL.Record({
    'id' : IDL.Nat,
    'name' : IDL.Text,
    'authorAddress' : IDL.Principal,
    'totalSupply' : IDL.Nat,
    'author' : IDL.Text,
    'initialRoyalty' : IDL.Nat,
    'price' : IDL.Nat,
    'resaleRoyalty' : IDL.Nat,
    'transactionCount' : IDL.Nat,
  });
  return IDL.Service({
    'buyNFT' : IDL.Func([IDL.Nat], [NFTOwnership], []),
    'buyResaleNFT' : IDL.Func([IDL.Nat, IDL.Principal], [NFTOwnership], []),
    'cancelResalePrice' : IDL.Func([IDL.Nat], [NFTOwnership], []),
    'createBook' : IDL.Func(
        [
          IDL.Nat,
          IDL.Text,
          IDL.Text,
          IDL.Principal,
          IDL.Nat,
          IDL.Nat,
          IDL.Nat,
          IDL.Nat,
        ],
        [BookCreatedEvent],
        [],
      ),
    'getAllBooks' : IDL.Func([], [IDL.Vec(Book)], ['query']),
    'getBook' : IDL.Func([IDL.Nat], [IDL.Opt(Book)], ['query']),
    'getNFTPurchaseInfo' : IDL.Func(
        [IDL.Nat],
        [IDL.Opt(IDL.Tuple(IDL.Nat, IDL.Nat))],
        ['query'],
      ),
    'getUniqueOwners' : IDL.Func([IDL.Nat], [IDL.Nat], ['query']),
    'setResalePrice' : IDL.Func([IDL.Nat, IDL.Nat], [NFTOwnership], []),
    'transferNFT' : IDL.Func([IDL.Nat, IDL.Principal], [NFTOwnership], []),
  });
};
export const init = ({ IDL }) => { return []; };
