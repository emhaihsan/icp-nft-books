import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface Book {
  'id' : bigint,
  'name' : string,
  'authorAddress' : Principal,
  'totalSupply' : bigint,
  'author' : string,
  'initialRoyalty' : bigint,
  'price' : bigint,
  'resaleRoyalty' : bigint,
  'transactionCount' : bigint,
}
export interface BookCreatedEvent {
  'id' : bigint,
  'name' : string,
  'authorAddress' : Principal,
  'totalSupply' : bigint,
  'author' : string,
  'initialRoyalty' : bigint,
  'price' : bigint,
  'resaleRoyalty' : bigint,
}
export interface NFTOwnership {
  'owner' : Principal,
  'bookId' : bigint,
  'resalePrice' : [] | [bigint],
}
export interface _SERVICE {
  'buyNFT' : ActorMethod<[bigint], NFTOwnership>,
  'buyResaleNFT' : ActorMethod<[bigint, Principal], NFTOwnership>,
  'cancelResalePrice' : ActorMethod<[bigint], NFTOwnership>,
  'createBook' : ActorMethod<
    [bigint, string, string, Principal, bigint, bigint, bigint, bigint],
    BookCreatedEvent
  >,
  'getAllBooks' : ActorMethod<[], Array<Book>>,
  'getBook' : ActorMethod<[bigint], [] | [Book]>,
  'getNFTPurchaseInfo' : ActorMethod<[bigint], [] | [[bigint, bigint]]>,
  'getUniqueOwners' : ActorMethod<[bigint], bigint>,
  'setResalePrice' : ActorMethod<[bigint, bigint], NFTOwnership>,
  'transferNFT' : ActorMethod<[bigint, Principal], NFTOwnership>,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
