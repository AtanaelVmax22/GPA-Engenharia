
# GPA Engenharia - Importmap

pin "application"

# Turbo Rails
pin "@hotwired/turbo-rails", to: "turbo.min.js"

# Stimulus
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"

# Controllers do GPA Engenharia
pin_all_from "app/javascript/controllers", under: "controllers"
