require 'spec_helper'

describe SystemHooksService, services: true do
  let(:user)          { create :user }
  let(:project)       { create :project }
  let(:project_member) { create :project_member }
  let(:key)           { create(:key, user: user) }
  let(:group)         { create(:group) }
  let(:group_member)  { create(:group_member) }

  context 'event data' do
    it { expect(event_data(user, :create)).to include(:event_name, :name, :created_at, :updated_at, :email, :user_id, :username) }
    it { expect(event_data(user, :destroy)).to include(:event_name, :name, :created_at, :updated_at, :email, :user_id, :username) }
    it { expect(event_data(project, :create)).to include(:event_name, :name, :created_at, :updated_at, :path, :project_id, :owner_name, :owner_email, :project_visibility) }
    it { expect(event_data(project, :update)).to include(:event_name, :name, :created_at, :updated_at, :path, :project_id, :owner_name, :owner_email, :project_visibility) }
    it { expect(event_data(project, :destroy)).to include(:event_name, :name, :created_at, :updated_at, :path, :project_id, :owner_name, :owner_email, :project_visibility) }
    it { expect(event_data(project_member, :create)).to include(:event_name, :created_at, :updated_at, :project_name, :project_path, :project_path_with_namespace, :project_id, :user_name, :user_username, :user_email, :user_id, :access_level, :project_visibility) }
    it { expect(event_data(project_member, :destroy)).to include(:event_name, :created_at, :updated_at, :project_name, :project_path, :project_path_with_namespace, :project_id, :user_name, :user_username, :user_email, :user_id, :access_level, :project_visibility) }
    it { expect(event_data(key, :create)).to include(:username, :key, :id) }
    it { expect(event_data(key, :destroy)).to include(:username, :key, :id) }

    it do
      project.old_path_with_namespace = 'renamed_from_path'
      expect(event_data(project, :rename)).to include(
        :event_name, :name, :created_at, :updated_at, :path, :project_id,
        :owner_name, :owner_email, :project_visibility,
        :old_path_with_namespace
      )
    end
    it do
      project.old_path_with_namespace = 'transfered_from_path'
      expect(event_data(project, :transfer)).to include(
        :event_name, :name, :created_at, :updated_at, :path, :project_id,
        :owner_name, :owner_email, :project_visibility,
        :old_path_with_namespace
      )
    end

    it do
      expect(event_data(group, :create)).to include(
        :event_name, :name, :created_at, :updated_at, :path, :group_id,
        :owner_name, :owner_email
      )
    end
    it do
      expect(event_data(group, :destroy)).to include(
        :event_name, :name, :created_at, :updated_at, :path, :group_id,
        :owner_name, :owner_email
      )
    end
    it do
      expect(event_data(group_member, :create)).to include(
        :event_name, :created_at, :updated_at, :group_name, :group_path,
        :group_id, :user_id, :user_username, :user_name, :user_email, :group_access
      )
    end
    it do
      expect(event_data(group_member, :destroy)).to include(
        :event_name, :created_at, :updated_at, :group_name, :group_path,
        :group_id, :user_id, :user_username, :user_name, :user_email, :group_access
      )
    end
  end

  context 'event names' do
    it { expect(event_name(user, :create)).to eq "user_create" }
    it { expect(event_name(user, :destroy)).to eq "user_destroy" }
    it { expect(event_name(project, :create)).to eq "project_create" }
    it { expect(event_name(project, :destroy)).to eq "project_destroy" }
    it { expect(event_name(project, :rename)).to eq "project_rename" }
    it { expect(event_name(project, :transfer)).to eq "project_transfer" }
    it { expect(event_name(project, :update)).to eq "project_update" }
    it { expect(event_name(project_member, :create)).to eq "user_add_to_team" }
    it { expect(event_name(project_member, :destroy)).to eq "user_remove_from_team" }
    it { expect(event_name(key, :create)).to eq 'key_create' }
    it { expect(event_name(key, :destroy)).to eq 'key_destroy' }
    it { expect(event_name(group, :create)).to eq 'group_create' }
    it { expect(event_name(group, :destroy)).to eq 'group_destroy' }
    it { expect(event_name(group_member, :create)).to eq 'user_add_to_group' }
    it { expect(event_name(group_member, :destroy)).to eq 'user_remove_from_group' }
  end

  def event_data(*args)
    SystemHooksService.new.send :build_event_data, *args
  end

  def event_name(*args)
    SystemHooksService.new.send :build_event_name, *args
  end
end
