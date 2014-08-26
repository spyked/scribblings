data Fruit =
    Apples
  | Pears
  | Oranges
  | Tomatoes
  deriving (Show, Eq)

data Bucket a = MkBucket
  { bucketObject  :: a
  , bucketQty     :: Int
  } deriving (Show, Eq)

type MultiBucket a = [Bucket a]

getBucket :: Eq a => a -> MultiBucket a -> Maybe (Bucket a)
getBucket obj mb = case filter isEqual mb of
  []      -> Nothing
  (x : _) -> Just x
  where isEqual x = bucketObject x == obj

newtype Nat1 = Nat1 { fromNat1 :: Int }
  deriving (Show, Eq)
mkNat :: Int -> Nat1
mkNat n = if n < 0
  then error "Only positive numbers are permitted"
  else Nat1 n

data Nat2 = Z | S Nat2
  deriving (Show, Eq)
