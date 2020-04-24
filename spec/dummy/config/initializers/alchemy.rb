# frozen_string_literal: true

Alchemy.user_class_name = "DummyUser"
Alchemy.signup_path = "/admin/pages" unless Rails.env.test?
