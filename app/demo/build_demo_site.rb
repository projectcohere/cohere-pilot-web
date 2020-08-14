require "demo_ext"

class BuildDemoSite < ::Command
  # -- constants --
  class Sheets < ::Option
    option(:application)
    option(:demo)
  end

  class Roles < ::Option
    option(:applicant)
  end

  module Paths
    # -- destinations
    Demo = Pathname.new("./demo")
    DemoStorage = Demo.join("storage")

    # -- sources
    Public = Pathname.new("./public")
    Assets = Public.join("assets")
    Macros = Pathname.new("./macros")
  end

  # -- lifetime --
  def initialize(repo = DemoRepo.new, store = DemoStore.new)
    @repo = repo
    @store = store
  end

  # -- command --
  def call
    scaffold_dir

    # mock services
    mock_service(User::Repo, @repo)
    mock_service(InMemoryStore, @store)

    # create pages
    create_page("index.html", render.landing)
    create_page("1", render.a01_phone, role: Roles::Applicant)
    create_page("1", render.s01_sign_in)
    create_page("2", render.s02_source_list)
    create_page("3", render.s03_source_start_case)
  end

  # -- helpers --
  private def scaffold_dir
    # create clearn root dir (remove demo_dir's contents instead of the
    # dir itself so that demo-server doesn't error on rebuilt paths)
    Paths::Demo.glob("*").each(&:rmtree) if Paths::Demo.exist?
    Paths::Demo.mkpath

    # symlink public files
    Paths::Public.children.each do |public_path|
      src = public_path.relative_path_from(Paths::Demo)
      dst = Paths::Demo.join(src.basename)
      dst.make_symlink(src)
    end

    # symlink namespaced css files
    Paths::Assets.children.each do |asset_path|
      Sheets.each do |name|
        if asset_path.basename.fnmatch("#{name}-*.css")
          src = asset_path.basename
          dst = asset_path.sub("#{name}-", "#{name}.self-")
          dst.make_symlink(src) if not dst.exist?
        end
      end
    end

    # create static storage dir to replace activestorage
    Paths::DemoStorage.mkpath

    # symlink macros into storage
    Paths::Macros.children.each do |macro_path|
      if macro_path.extname == ".png"
        src = macro_path.relative_path_from(Paths::DemoStorage)
        dst = Paths::DemoStorage.join(src.basename)
        dst.make_symlink(src)
      end
    end
  end

  private def mock_service(type, value)
    name = Service::Container.get_name(type)
    Service::Container.attributes[name] = value
  end

  private def create_page(name, html, role: "")
    path = Paths::Demo.join(role.to_s, name)
    path.parent.mkpath
    path.write(html)
  end

  private def render
    return DemoRenderer.new(repo: @repo)
  end
end
