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
    create_page("index.html", render.landing)
    create_page("1", render.s01_sign_in)
    create_page("2", render.s02_source_list)
    create_page("3", render.s03_source_start_case)
  end

  # -- helpers --
  private def scaffold_dir
    @demo_dir.glob("*").each(&:rmtree) if @demo_dir.exist?
    @demo_dir.mkpath

    # symlink assets from public
    @public_dir.children.each do |public_path|
      src = public_path.relative_path_from(@demo_dir)
      dst = @demo_dir.join(src.basename)
      dst.make_symlink(src)
    end

    # symlink namespaced css files
    sheets = %w[application demo]

    @public_dir.join("assets").children.each do |asset|
      sheets.each do |name|
        if asset.basename.fnmatch("#{name}-*.css")
          src = asset.basename
          dst = asset.sub("#{name}-", "#{name}.self-")
          dst.make_symlink(src) if not dst.exist?
        end
      end
    end
  end

  private def link_stylesheet(name, asset)
    src = asset.basename
    dst = asset.sub("#{name}-", "#{name}.self-")
    dst.make_symlink(src) if not dst.exist?
  end

  private def mock_service(type, value)
    name = Service::Container.get_name(type)
    Service::Container.attributes[name] = value
  end

  private def create_page(name, html)
    path = @demo_dir.join("#{name}")
    path.write(html)
  end

  private def render
    return DemoRenderer.new(repo: @repo)
  end
end
