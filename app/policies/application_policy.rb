class ApplicationPolicy
  attr_reader :user, :request, :record

  def initialize(context, record)
    @user, @request = context
    @record = record
  end

  def index?
    true
  end

  def show?
    index?
  end

  def search?
    index?
  end

  def new?
    create?
  end

  def create?
    unbanned?
  end

  def edit?
    update?
  end

  def update?
    unbanned?
  end

  def destroy?
    update?
  end

  def unbanned?
    user.is_member? && !user.is_banned? && verified?
  end

  def verified?
    user.is_verified? || user.is_gold? || !user.requires_verification?
  end

  def policy(object)
    Pundit.policy!([user, request], object)
  end

  def permitted_attributes
    []
  end

  def permitted_attributes_for_create
    permitted_attributes
  end

  def permitted_attributes_for_update
    permitted_attributes
  end

  def permitted_attributes_for_new
    permitted_attributes_for_create
  end

  def permitted_attributes_for_edit
    permitted_attributes_for_update
  end

  # The list of attributes that are permitted to be returned by the API.
  def api_attributes
    record.class.attribute_types.reject { |name, attr| attr.type.in?([:inet, :tsvector]) }.keys.map(&:to_sym)
  end

  # The list of attributes that are permitted to be used as data-* attributes
  # in tables and in the <body> tag on show pages.
  def html_data_attributes
    data_attributes = record.class.columns.select do |column|
      column.type.in?([:integer, :boolean]) && !column.array?
    end.map(&:name).map(&:to_sym)

    api_attributes & data_attributes
  end
end
