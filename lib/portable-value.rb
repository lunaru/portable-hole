class PortableValue < ActiveRecord::Base
  belongs_to        :model, :polymorphic => true
  belongs_to        :group, :polymorphic => true

  before_save       :set_group

  def set_group
    config = eval(self.model_type).eav_configuration
    if config[self.context].present?
      if config[self.context][:group].present?
        self.group = model.send(config[self.context][:group])
      end
    end
  end
end