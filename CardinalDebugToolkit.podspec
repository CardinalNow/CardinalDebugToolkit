Pod::Spec.new do |s|
  s.name = "CardinalDebugToolkit"
  s.version = "1.2"
  s.summary = "iOS debug toolkit"
  s.description = <<-DESC
iOS debug toolkit that lets you build a comprehensive debug panel to access from inside an app.
DESC
  s.homepage = "https://github.com/CardinalNow/CardinalDebugToolkit"
  s.screenshots = "https://github.com/CardinalNow/CardinalDebugToolkit/raw/master/Documentation/Assets/screenshot.png"
  s.license = "MIT"
  s.author = { "Robin Kunde" => "rkunde@cardinalsolutions.com" }
  s.platform = :ios, "9.0"
  s.source = { :git => "https://github.com/CardinalNow/CardinalDebugToolkit.git", :tag => "#{s.version}" }
  s.source_files = "Sources/**/*.swift"
  s.resource_bundles = {
    'CardinalDebugToolkit-Storyboards' => ['Storyboards/**/*.{storyboard,xib}']
  }
  s.dependency "KeychainAccess", "~> 3.0"
end
