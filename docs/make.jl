# Copyright 2025 Luis M. B. Varona and Nathaniel Johnston
#
# Licensed under the MIT license <LICENSE or
# http://opensource.org/licenses/MIT>, at your option. This file may not be
# copied, modified, or distributed except according to those terms.

using QuantumStateTransfer
using Documenter

DocMeta.setdocmeta!(
    QuantumStateTransfer, :DocTestSetup, :(using QuantumStateTransfer); recursive=true
)

makedocs(;
    modules=[QuantumStateTransfer],
    authors="Luis M. B. Varona <lbvarona@mta.ca>, Nathaniel Johnston <njohnston@mta.ca>",
    sitename="QuantumStateTransfer.jl",
    format=Documenter.HTML(;
        canonical="https://GraphQuantum.github.io/QuantumStateTransfer.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=["Home" => "index.md"],
)

deploydocs(; repo="github.com/GraphQuantum/QuantumStateTransfer.jl", devbranch="main")
