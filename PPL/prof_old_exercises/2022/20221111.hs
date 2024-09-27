data BTree a = BEmpty | BNode a (BTree a) (BTree a) deriving Eq
bleaf x = BNode x BEmpty BEmpty

instance Show a => Show (BTree a) where
    show BEmpty = ""
    show (BNode v x y) = "<" ++ show x ++ " " ++ show v ++ " " ++ show y ++ ">" 

t1 = BNode 1 (bleaf 2) (BNode 3 (bleaf 4) (bleaf 5))
t2 = BNode 1 (BNode 2 (bleaf 3) (bleaf 4)) (bleaf 5)

bmap f BEmpty = BEmpty
bmap f (BNode v x y) = BNode (f v) (bmap f x) (bmap f y)

-- infinite binary trees
binf :: Integer -> BTree Integer
binf x = let t = binf (x+1) 
         in BNode x t t 

btake :: Integer -> BTree a -> BTree a
btake _ BEmpty = BEmpty
btake 0 _ = BEmpty
btake n (BNode v l r) = BNode v (btake (n-1) l) (btake (n-1) r)

-- instance of Functor?
instance Functor BTree where
    fmap = bmap

instance Foldable BTree where
    foldr f z BEmpty = z
    foldr f z (BNode x l r) = f x (foldr f (foldr f z r) l)

-- instance Applicative BTree where
--     pure x = bleaf x
--     BEmpty <*> _ = BEmpty
--     _ <*> BEmpty = BEmpty
--     (BNode x1 l1 r1) <*> (BNode x2 l2 r2) = BNode (x1 x2) (l1 <*> l2) (r1 <*> r2)

BEmpty +-+ t = t
t +-+ BEmpty = t
(BNode x1 l1 r1) +-+ t = BNode x1 l1 (r1 +-+ t)

btconcat = foldr (+-+) BEmpty 
btconcatMap f t = btconcat $ fmap f t

instance Applicative BTree where
    pure = bleaf
    fs <*> xs = btconcatMap (\f -> fmap f xs) fs


-- inc function
inc :: (Functor f, Num a) => f a -> f a
inc = fmap (+1)

-- Applicative f
-- pure :: a -> f a
-- (<*>) :: f (a -> b) -> f a -> f b
-- 
-- [(+1),(*2)] <*> [1,2] = [2,4]
-- zip / ZipList
data ZL a = ZEmpty | ZCons a (ZL a) deriving Eq

instance Show a => Show (ZL a) where
    show ZEmpty = "{}"
    show (ZCons x ZEmpty) = "{" ++ show x ++ "}"
    show (ZCons x xs) = "{" ++ show x ++ "," ++ (drop 1 (show xs))

l1 = ZCons 1 (ZCons 2 (ZCons 3 ZEmpty))

toZipList :: [a] -> ZL a
toZipList [] = ZEmpty
toZipList (x:xs) = ZCons x (toZipList xs)

l2 = toZipList [1,3..5]

instance Functor ZL where
    fmap f ZEmpty = ZEmpty
    fmap f (ZCons x xs) = ZCons (f x) (fmap f xs)

instance Foldable ZL where
    foldr f z ZEmpty = z
    foldr f z (ZCons x xs) = f x (foldr f z xs)

instance Applicative ZL where
    pure x = ZCons x ZEmpty
    ZEmpty <*> _ = ZEmpty
    _ <*> ZEmpty = ZEmpty
    (ZCons f fs) <*> (ZCons x xs) = ZCons (f x) (fs <*> xs)


