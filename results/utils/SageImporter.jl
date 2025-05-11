# Copyright 2025 Luis M. B. Varona and Nathaniel Johnston
#
# Licensed under the MIT license <LICENSE-MIT or
# http://opensource.org/licenses/MIT>. This file may not be copied, mofified, or
# distributed except according to those terms.

module SageImporter

using Conda
using PyCall: pyimport

const ENV_NAME = "sage_env"
const CONDA_PATH = joinpath(Conda.PYTHONDIR, "conda")
const ENV_PATH = joinpath(dirname(Conda.PYTHONDIR), "envs", ENV_NAME)
const PYTHON_EXE = joinpath(ENV_PATH, "bin", "python")

export import_sage

function import_sage()
    ENV["PYTHON"] = PYTHON_EXE
    isdir(ENV_PATH) || Conda.create(Symbol(ENV_NAME))
    packages = read(`$CONDA_PATH list -n $ENV_NAME`, String)
    occursin(r"(?m)^\s*sage\s+", packages) || Conda.add("sage", Symbol(ENV_NAME))

    try
        sage = pyimport("sage.all")
        println("SageMath imported successfully.")
        return sage
    catch # The conda environment might not be properly initialized at first
        println("Failed to import SageMath. Initializing conda environment...")
        sage = pyimport("sage.all")
        println("SageMath imported successfully after initialization.")
        return sage
    end
end

end
