class SpreeImporter::AbilityDecorator
  include CanCan::Ability
  def initialize(user)
    if user.admin?
      can :read, Spree::ImportSourceFile
      can :update, Spree::ImportSourceFile
      can :create, Spree::ImportSourceFile
      can :destroy, Spree::ImportSourceFile
    end
  end
end

Spree::Ability.register_ability SpreeImporter::AbilityDecorator
