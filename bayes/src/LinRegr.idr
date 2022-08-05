module LinRegr

import Language.JSON
import Idris2JupyterVega.VegaLite
import Control.Monad.Bayes.Interface
import Control.Monad.Bayes.Sampler
import Control.Monad.Bayes.Weighted
import Control.Monad.Bayes.Population
import Control.Monad.Bayes.Sequential
import Control.Monad.Bayes.Traced.Static
import Control.Monad.Bayes.Inference.RMSMC

||| Params
public export
record Params where
  constructor MkParams
  mu : Double     -- mean
  c : Double      -- intercept
  s : Double      -- standard deviation

export
Show Params where
  show (MkParams mv cv sv) = "(m : " ++ show mv ++ ", c : " ++ show cv ++ ", std : " ++ show sv ++ ")"

||| Prior
export
linRegrPrior : MonadSample m => m Params
linRegrPrior = do
  mu <- normal 0 3
  c  <- normal 0 5
  s  <- uniform 1 3
  pure (MkParams mu c s)

||| Simulate linear regression data
export
mkLinRegrData : Nat -> IO (List (Double, Double))
mkLinRegrData n_datapoints = sampleIO $ do
  MkParams mu c s <- linRegrPrior
  let xs = map cast [0 ..  n_datapoints]
  ys <- sequence (map (\x => normal (mu * x + c) s) xs)
  pure (zip xs ys)

||| Linear regression model
export
linRegr : MonadInfer m => List (Double, Double) -> Params -> m Params
linRegr xys (MkParams m0 c0 s0) = do
  _ <- sequence (map (\(x, y_obs) => let logprob = toLogDomain (gsl_normal_pdf (m0 * x + c0) s0 y_obs)
                                     in  score logprob) xys)
  pure (MkParams m0 c0 s0)

||| Metropolis-Hastings inference over linear regression parameters
export
mhLinRegr
  :  (n_mhsteps : Nat)
  -> Nat
  -> IO (List Params)
mhLinRegr n_mhsteps n_datapoints = do
  dataset <- mkLinRegrData n_datapoints
  params  <- sampleIO $ prior $ mh n_mhsteps (linRegrPrior >>= linRegr dataset)
  pure (toList params)

||| RMSMC inference over linear regression parameters
export
rmsmcLinRegr
  :  (n_particles : Nat)
  -> (n_mhsteps : Nat)
  -> Nat
  -> IO (List Params)
rmsmcLinRegr n_particles n_mhsteps  n_datapoints = do
  dataset   <- mkLinRegrData n_datapoints
  let n_timesteps = n_particles
  particles <- sampleIO $ runPopulation $ rmsmc n_timesteps n_particles n_mhsteps (linRegrPrior >>= linRegr dataset)
  pure (map snd particles)

export
scatterGraph : List (Double, Double) -> VegaLite
scatterGraph vals = TopLevelSpec_0 $ MkTopLevelUnitSpec
    {Schema = Just "https://vega.github.io/schema/vega-lite/v5.json"}
    (Data_0 $ Data_0 $ DataSource_1 $ MkInlineData $ InlineDataset_3 $ map (\(x, y) => JObject [("x", JNumber x), ("y", JNumber y)]) vals)
    {description = Just "A scatterplot"}
    {encoding = Just $ MkFacetedEncoding
        {x = Just $ PositionDef_0 $ MkPositionFieldDef
            {field = Just $ Field_0 "x"}
            {type = Just StandardTypeQuantitative}
        }
        {y = Just $ PositionDef_0 $ MkPositionFieldDef
            {field = Just $ Field_0 "y"}
            {type = Just StandardTypeQuantitative}
        }
    }
    {mark = AnyMark_2 MarkPoint}
    -- (AnyMark_2 MarkBar)

    -- {
    --   "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
    --   "description": "A scatterplot showing horsepower and miles per gallons for various cars.",
    --   "data": {"url": "data/cars.json"},
    --   "mark": "point",
    --   "encoding": {
    --     "x": {"field": "Horsepower", "type": "quantitative"},
    --     "y": {"field": "Miles_per_Gallon", "type": "quantitative"}
    --   }
    -- }

export
barChart : String -> List (String, Double) -> VegaLite
barChart description vals = TopLevelSpec_0 $ MkTopLevelUnitSpec
    {Schema = Just "https://vega.github.io/schema/vega-lite/v5.json"}
    (Data_0 $ Data_0 $ DataSource_1 $ MkInlineData $ InlineDataset_3 $ map (\(name, x) => JObject [("a", JString name), ("b", JNumber x)]) vals)
    {description = Just description}
    {encoding = Just $ MkFacetedEncoding
        {x = Just $ PositionDef_0 $ MkPositionFieldDef
            {axis = Just $ Axis_0 $ MkAxis {labelAngle = Just $ LabelAngle_0 0}}
            {field = Just $ Field_0 "a"}
            {type = Just StandardTypeNominal}
        }
        {y = Just $ PositionDef_0 $ MkPositionFieldDef
            {field = Just $ Field_0 "b"}
            {type = Just StandardTypeQuantitative}
        }
    }
    (AnyMark_2 MarkBar)
