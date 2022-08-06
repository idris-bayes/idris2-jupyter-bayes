||| Linear regression using Monad Bayes
module LinRegrMB

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
  s  <- uniform 0.2 1.5
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
