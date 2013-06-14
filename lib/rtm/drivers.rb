# 
class Sereth::Drivers
  def load
    # Load rails drivers, or failing that just the sproject integration
    require_relative 'drivers/tilt'
    if defined? Rails
      require_relative 'drivers/rails'
    elsif defined? Sprockets
      require_relative 'drivers/sprockets' 
    end

    # Load the rake tasks
    require_relative 'drivers/rake' if defined? Rake
  end
end