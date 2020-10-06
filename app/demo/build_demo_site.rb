require "demo_ext"

class BuildDemoSite < ::Command
  # -- constants --
  class Sheet < ::Option
    option(:application)
    option(:demo)
  end

  module Paths
    # -- destinations
    Demo = Pathname.new("./demo")
    DemoStorage = Demo.join("storage")

    # -- sources
    Public = Pathname.new("./public")
    Assets = Public.join("assets")
    Macros = Pathname.new("./macros")
    DemoFiles = Pathname.new("./demo-files")
    Netlify = Pathname.new("./netlify.toml")
  end

  # -- lifetime --
  def initialize(repo = DemoRepo.new, store = DemoStore.new)
    @repo = repo
    @store = store
  end

  # -- command --
  def call
    scaffold_dir()

    # mock services
    mock_service(Partner::Repo, @repo)
    mock_service(User::Repo, @repo)
    mock_service(Chat::Repo, @repo)
    mock_service(InMemoryStore, @store)

    # create pages (TODO: could infer url from renderer ivars now)
    r = DemoRole
    create_page("index.html", render.landing)
    create_page("1", render.a01_communication, role: r::Applicant)
    create_page("2", render.a02_legal, role: r::Applicant)
    create_page("3", render.a03_language, role: r::Applicant)
    create_page("4", render.a04_questions, role: r::Applicant)
    create_page("5", render.a05_documents, role: r::Applicant)
    create_page("6", render.a06_enrolled, role: r::Applicant)
    create_page("1", render.c01_sign_in, role: r::CallCenter)
    create_page("2", render.c02_start_case, role: r::CallCenter)
    create_page("3", render.c03_form, role: r::CallCenter)
    create_page("4", render.c04_state_data, role: r::CallCenter)
    create_page("5", render.c05_view_cases, role: r::CallCenter)
    create_page("1", render.s01_case_alert, role: r::State)
    create_page("2", render.s02_form, role: r::State)
    create_page("3", render.s03_fpl, role: r::State)
    create_page("1", render.n01_inbox, role: r::Nonprofit)
    create_page("2", render.n02_form, role: r::Nonprofit)
    create_page("3", render.n03_chat, role: r::Nonprofit)
    create_page("4", render.n04_macros, role: r::Nonprofit)
    create_page("5", render.n05_documents, role: r::Nonprofit)
    create_page("6", render.n06_determination, role: r::Nonprofit)
    create_page("7", render.n07_referrals, role: r::Nonprofit)
    create_page("8", render.n08_reports, role: r::Nonprofit)
  end

  # -- helpers --
  private def scaffold_dir
    # create clearn root dir (remove demo_dir's contents instead of the
    # dir itself so that demo-server doesn't error on rebuilt paths)
    Paths::Demo.glob("*").each(&:rmtree) if Paths::Demo.exist?
    Paths::Demo.mkpath

    # symlink netlify config
    create_symlink(Paths::Netlify, Paths::Demo)

    # symlink public files
    Paths::Public.children.each do |public_path|
      create_symlink(public_path, Paths::Demo)
    end

    # symlink namespaced css files
    Paths::Assets.children.each do |asset_path|
      Sheet.each do |name|
        if asset_path.basename.fnmatch("#{name}-*.css")
          src = asset_path.basename
          dst = asset_path.sub("#{name}-", "#{name}.self-")
          dst.make_symlink(src) if not dst.exist?
        end
      end
    end

    # create static storage dir to replace activestorage
    Paths::DemoStorage.mkpath

    # symlink demo files into storage
    Paths::DemoFiles.children.each do |file_path|
      create_symlink(file_path, Paths::DemoStorage)
    end

    # symlink macros into storage
    Paths::Macros.children.each do |macro_path|
      if macro_path.extname == ".png"
        create_symlink(macro_path, Paths::DemoStorage)
      end
    end
  end

  private def mock_service(type, value)
    type.define_singleton_method(:get) do
      value
    end
  end

  private def create_symlink(path, dst_dir)
    src = path.relative_path_from(dst_dir)
    dst = dst_dir.join(src.basename)
    dst.make_symlink(src)
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
