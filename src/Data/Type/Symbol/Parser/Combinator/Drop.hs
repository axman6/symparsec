{-# LANGUAGE UndecidableInstances #-} -- for natural subtraction

module Data.Type.Symbol.Parser.Combinator.Drop ( Drop, Drop' ) where

import Data.Type.Symbol.Parser.Types
import Data.Type.Symbol.Parser.Common
import GHC.TypeLits
import DeFun.Core ( type (~>), type App )

type Drop :: Natural -> Parser Natural ()
type family Drop n where
    Drop 0 =
        '(FailChSym "Drop" (ErrParserLimitation "can't drop 0"), DropEndSym, 0)
    Drop n = Drop' n

-- | Unsafe 'Drop' which doesn't check for 0. May get stuck.
type Drop' :: Natural -> Parser Natural ()
type Drop' n = '(DropChSym, DropEndSym, n)

type DropCh :: ParserCh Natural ()
type family DropCh ch n where
    DropCh _ 1 = Done '()
    DropCh _ n = Cont (n-1)

type DropEnd :: ParserEnd Natural ()
type family DropEnd n where
    DropEnd 0 = Right '()
    DropEnd n = Left (EBase "Drop"
      ( Text "tried to drop "
        :<>: ShowType n :<>: Text " chars from empty symbol"))

type DropChSym :: ParserChSym Natural ()
data DropChSym f
type instance App DropChSym f = DropChSym1 f

type DropChSym1 :: Char -> Natural ~> Result Natural ()
data DropChSym1 ch n
type instance App (DropChSym1 ch) n = DropCh ch n

type DropEndSym :: ParserEndSym Natural ()
data DropEndSym n
type instance App DropEndSym n = DropEnd n
