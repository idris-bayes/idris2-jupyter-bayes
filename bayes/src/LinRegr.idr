||| Linear regression using ProbFX on top of MonadBayes
module LinRegr

{- Monad Bayes -}
import Control.Monad.Bayes.Interface
import Control.Monad.Bayes.Sampler
import Control.Monad.Bayes.Weighted
import Control.Monad.Bayes.Population
import Control.Monad.Bayes.Sequential
import Control.Monad.Bayes.Traced.Static
import Control.Monad.Bayes.Inference.SMC
import Control.Monad.Bayes.Inference.RMSMC

{- ProbFX -}
import ProbFX.Model as PFX
import ProbFX.Inference.MBAYES as PFX
import LinRegrPFX as PFX

||| Simulating linear regression
export
simLinRegr : (n_datapoints : Nat) -> IO (List (Double, Double))
simLinRegr n_datapoints = do
  let xs        = map cast [0 .. n_datapoints]
      linRegr = PFX.toMBayes PFX.envExampleSim (PFX.linRegr xs)

  (ys, env_out) <- sampleIO $ prior linRegr
  pure (zip xs ys)

||| MH inference on linear regression
export
mhLinRegr : (n_mhsteps : Nat) -> (n_datapoints : Nat) -> IO (List Double, List Double)
mhLinRegr n_mhsteps n_datapoints = do
  let xs      = map cast [0 .. n_datapoints]
      linRegr = PFX.toMBayes (PFX.envExampleInf xs) (PFX.linRegr xs)

  mh_output <- the (IO (Vect (S n_mhsteps) (List Double, Env LinRegrEnv)))
                   (sampleIO $ prior $ mh n_mhsteps linRegr )

  let env_outs : List (Env LinRegrEnv) = map snd (toList mh_output)
      mus : List Double                = gets "mu" env_outs
      cs  : List Double                = gets "c" env_outs
  pure (mus, cs)

||| SMC inference on linear regression, using monad bayes
export
smcLinRegr : (n_timesteps : Nat) -> (n_particles : Nat) -> (n_datapoints : Nat) -> IO (List Double, List Double)
smcLinRegr n_timesteps n_particles n_datapoints = do
  let xs      = map cast [0 .. n_datapoints]
      linRegr = PFX.toMBayes (PFX.envExampleInf xs) (PFX.linRegr xs)

  smc_output <- the (IO (List (Log Double, (List Double, Env LinRegrEnv))))
                   (sampleIO $ runPopulation $ smc n_timesteps n_particles linRegr )

  let env_outs : List (Env LinRegrEnv) = map (snd . snd) (toList smc_output)
      mus : List Double                = gets "mu" env_outs
      cs  : List Double                = gets "c" env_outs
  pure (mus, cs)

||| RMSMC inference on linear regression, using monad bayes
export
rmsmcLinRegr : (n_timesteps : Nat) -> (n_particles : Nat) -> (n_mhsteps : Nat) -> (n_datapoints : Nat) -> IO (List Double, List Double)
rmsmcLinRegr  n_timesteps n_particles n_mhsteps n_datapoints = do
  let xs      = map cast [0 .. n_datapoints]
      linRegr = PFX.toMBayes (PFX.envExampleInf xs) (PFX.linRegr xs)

  rmsmc_output <- the (IO (List (Log Double, (List Double, Env LinRegrEnv))))
                      (sampleIO $ runPopulation $ rmsmc n_timesteps n_particles n_mhsteps linRegr )

  let env_outs : List (Env LinRegrEnv) = map (snd . snd) (toList rmsmc_output)
      mus : List Double                = gets "mu" env_outs
      cs  : List Double                = gets "c"  env_outs
  pure (mus, cs)
