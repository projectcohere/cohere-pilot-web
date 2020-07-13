class BuildDemoSite < ::Command
  # -- lifetime --
  def initialize(render = DemoRenderer.new)
    @render = render
    @demo_dir ||= Pathname.new("./demo")
    @public_dir ||= Pathname.new("./public")
  end

  # -- command --
  def call
    # scaffold demo directory
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

    # create pages
    create_page("s01_sign_in", @render.s01_sign_in)
  end

  # -- helpers --
  private def create_page(name, html)
    path = @demo_dir.join("#{name}.html")
    path.write(html)
  end
end
