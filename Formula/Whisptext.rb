class Whisptext < Formula
  desc "Blazing fast local AI Voice-to-Cursor transcription agent for macOS"
  homepage "https://github.com/alexzaak/whisp-text"
  
  # For public tap distribution, this points to your repository URL
  url "https://github.com/alexzaak/whisp-text.git", branch: "main"
  version "1.0.0"
  license "MIT"

  # Apple Silicon / macOS 14 requirement for WhisperKit and Swift features
  depends_on xcode: ["15.0", :build]
  depends_on macos: :sonoma
  depends_on arch: :arm64

  def install
    # Execute the existing build script to compile via SPM
    system "./build.sh"

    # Install the compiled macOS App Bundle into the Homebrew Cellar prefix
    prefix.install "build/WhispText.app"
  end

  def caveats
    <<~EOS
      WhispText was compiled and installed successfully!
      
      To make the app easily accessible from Spotlight and Launchpad, run the 
      following command to symlink it into your System Applications folder:
      
        ln -sf #{opt_prefix}/WhispText.app /Applications/WhispText.app

      ⚠️ Permissions Notice:
      Because WhispText acts as a global text-injection agent, you MUST grant it
      Microphone and Accessibility security permissions under macOS System Settings 
      upon its first launch.
      
      To start the application from the terminal:
        open /Applications/WhispText.app
    EOS
  end
end
