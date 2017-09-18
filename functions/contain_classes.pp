function psick::contain_classes(Variant[Hash,Array,String] $classes,
Optional[String] $dependency = undef) {
  case $classes {
    Array: {
      $classes.each |$c| {
        if $c != '' {
          contain $c
          if $dependency {
            Class[$dependency] -> Class[$c]
          }
        }
      }
    }
    Hash: {
      $classes.each |$n,$c| {
        if $c != '' {
          contain $c
          if $dependency {
            Class[$dependency] -> Class[$c]
          }
        }
      }
    }
    String: {
      if $classes != '' {
        contain $classes
        if $dependency {
          Class[$dependency] -> Class[$classes]
        }
      }
    }
    default: {}
  }
}
