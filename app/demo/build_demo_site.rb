class BuildDemoSite < ::Command
  # -- lifetime --
  def initialize(repo = DemoRepo.new, store = DemoStore.new)
    @repo = repo
    @store = store
    @demo_dir ||= Pathname.new("./demo")
    @public_dir ||= Pathname.new("./public")
  end

  # -- command --
  def call
    scaffold_dir

    # mock services
    mock_service(User::Repo, @repo)
    mock_service(InMemoryStore, @store)

    # create pages
    create_page("s01_sign_in", render.s01_sign_in)
    create_page("s02_source_list", render.s02_source_list)
  end

  # -- helpers --
  private def scaffold_dir
    @demo_dir.rmtree if @demo_dir.exist?
    @demo_dir.mkpath

    # symlink assets from public
    @public_dir.children.each do |public_path|
      src = public_path.relative_path_from(@demo_dir)
      dst = @demo_dir.join(src.basename)
      dst.make_symlink(src)
    end

    # namespace application css files
    @public_dir.join("assets").children.each do |asset|
      if asset.basename.fnmatch("application-*.css")
        src = asset.basename
        dst = asset.sub("application-", "application.self-")
        dst.make_symlink(src) if not dst.exist?
      end
    end
  end

  private def mock_service(type, value)
    name = Service::Container.get_name(type)
    Service::Container.attributes[name] = value
  end

  private def create_page(name, html)
    path = @demo_dir.join("#{name}.html")
    path.write(html)
  end

  private def render
    return DemoRenderer.new(repo: @repo)
  end
end
