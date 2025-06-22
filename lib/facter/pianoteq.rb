require 'puppet/pianoteq/repositories/preference_repository'

Facter.add(:pianoteq_activated) do
  setcode do
    preference_repository = Pianoteq::Repositories::PreferenceRepository.new
    lkey_preference = preference_repository.find('LKey')
    !lkey_preference.nil?
  end
end