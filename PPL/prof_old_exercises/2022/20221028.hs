
-- fact :: Integer -> Integer
fact 0 = 1
fact n = n * fact (n - 1)

len :: [a] -> Integer
len [] = 0
len (x:xs) = 1 + len xs

rev :: [a] -> [a]  -- mmhh, quadratic
rev [] = []
rev (x:xs) = (rev xs) ++ [x]


-- foldleft of Scheme
foldleft :: (a -> b -> b) -> b -> [a] -> b
foldleft f z [] = z
foldleft f z (x:xs) = foldleft f (f x z) xs

rev' :: [a] -> [a]
rev' = foldleft (:) []  -- pointfree

data TrafficLight = Red | Yellow | Green

instance Show TrafficLight where
    show Red = "red"
    show Yellow = "yellow"
    show Green = "green"

instance Eq TrafficLight where
    Red == Red = True
    Yellow == Yellow = True
    Green == Green = True
    _ == _ = False
