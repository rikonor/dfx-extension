use std::path::PathBuf;

use anyhow::Error;
use clap::Parser;

#[derive(Parser)]
struct Cli {
    #[clap(subcommand)]
    subcmd: SubCommand,

    /// Path to dfx cache
    #[arg(long("dfx-cache-path"), env = "DFX_CACHE_PATH", global = true)]
    cache: Option<PathBuf>,
}

#[derive(Parser)]
enum SubCommand {
    Print,
}

#[tokio::main]
async fn main() -> Result<(), Error> {
    let _cli = Cli::parse();

    Ok(())
}
