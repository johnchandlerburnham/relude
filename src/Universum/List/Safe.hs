{-# LANGUAGE CPP         #-}
{-# LANGUAGE Trustworthy #-}

module Universum.List.Safe
       ( list
       , uncons
       , unsnoc
#if ( __GLASGOW_HASKELL__ >= 800 )
       , whenNotNull
       , whenNotNullM
#endif
       ) where

import Data.Functor (fmap)

#if ( __GLASGOW_HASKELL__ >= 800 )
import Control.Applicative (Applicative)
import Control.Monad (Monad (..))
import Data.List.NonEmpty as X (NonEmpty (..))

import Universum.Applicative (pass)
#endif

import Universum.Container (foldr)
import Universum.Monad (Maybe (..))

-- | Returns default list if given list is empty.
-- Otherwise applies given function to every element.
--
-- >>> list [True] even []
-- [True]
-- >>> list [True] even [1..5]
-- [False,True,False,True,False]
list :: [b] -> (a -> b) -> [a] -> [b]
list def f xs = case xs of
    [] -> def
    _  -> fmap f xs

-- | Destructuring list into its head and tail if possible. This function is total.
--
-- >>> uncons []
-- Nothing
-- >>> uncons [1..5]
-- Just (1,[2,3,4,5])
-- >>> uncons (5 : [1..5]) >>= \(f, l) -> pure $ f == length l
-- Just True
uncons :: [a] -> Maybe (a, [a])
uncons []     = Nothing
uncons (x:xs) = Just (x, xs)

-- | Similar to 'uncons' but destructuring list into its last element and
-- everything before it.
unsnoc :: [x] -> Maybe ([x],x)
unsnoc = foldr go Nothing
  where
    go x mxs = Just (case mxs of
       Nothing      -> ([], x)
       Just (xs, e) -> (x:xs, e))

#if ( __GLASGOW_HASKELL__ >= 800 )
-- | Performs given action over 'NonEmpty' list if given list is non empty.
whenNotNull :: Applicative f => [a] -> (NonEmpty a -> f ()) -> f ()
whenNotNull []     _ = pass
whenNotNull (x:xs) f = f (x :| xs)
{-# INLINE whenNotNull #-}

-- | Monadic version of 'whenNotNull'.
whenNotNullM :: Monad m => m [a] -> (NonEmpty a -> m ()) -> m ()
whenNotNullM ml f = ml >>= \l -> whenNotNull l f
{-# INLINE whenNotNullM #-}
#endif