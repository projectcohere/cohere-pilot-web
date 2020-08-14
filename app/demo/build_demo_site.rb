require "demo_ext"

class BuildDemoSite < ::Command
  # -- lifetime --
  def initialize(repo = DemoRepo.new, store = DemoStore.new)
    @repo = repo
    @store = store
    @demo_dir ||= Pathname.new("./demo")
    @demo_storage_dir ||= @demo_dir.join("storage")
    @public_dir ||= Pathname.new("./public")
    @macros_dir ||= Pathname.new("./macros")
  end

  # -- command --
  def call
    scaffold_dir

    # mock services
    mock_service(User::Repo, @repo)
    mock_service(InMemoryStore, @store)

    # create pages
    create_page("index.html", render.landing)
    create_page("applicant/1", render.a01_phone)
    create_page("1", render.s01_sign_in)
    create_page("2", render.s02_source_list)
    create_page("3", render.s03_source_start_case)
  end

  # -- helpers --
  private def scaffold_dir
    # create clearn root dir (remove demo_dir's contents instead of the
    # dir itself so that demo-server doesn't error on rebuilt paths)
    @demo_dir.glob("*").each(&:rmtree) if @demo_dir.exist?
    @demo_dir.mkpath

    # symlink public files
    @public_dir.children.each do |public_path|
      src = public_path.relative_path_from(@demo_dir)
      dst = @demo_dir.join(src.basename)
      dst.make_symlink(src)
    end

    # symlink namespaced css files
    sheets = %w[application demo]

    @public_dir.join("assets").children.each do |asset_path|
      sheets.each do |name|
        if asset_path.basename.fnmatch("#{name}-*.css")
          src = asset_path.basename
          dst = asset_path.sub("#{name}-", "#{name}.self-")
          dst.make_symlink(src) if not dst.exist?
        end
      end
    end

    # create static storage dir to replace activestorage
    @demo_storage_dir.mkpath

    # symlink macros into storage
    @macros_dir.children.each do |macro_path|
      if macro_path.extname == ".png"
        src = macro_path.relative_path_from(@demo_storage_dir)
        dst = @demo_storage_dir.join(src.basename)
        dst.make_symlink(src)
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
    path.parent.mkpath
    path.write(html)
  end

  private def render
    return DemoRenderer.new(repo: @repo)
  end
end
