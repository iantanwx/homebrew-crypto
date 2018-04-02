class GnuWget < Formula
  desc "Internet file retriever built against LibreSSL"
  homepage "https://www.gnu.org/software/wget/"
  url "https://ftp.gnu.org/gnu/wget/wget-1.19.4.tar.gz"
  mirror "https://ftpmirror.gnu.org/wget/wget-1.19.4.tar.gz"
  sha256 "93fb96b0f48a20ff5be0d9d9d3c4a986b469cb853131f9d5fe4cc9cecbc8b5b5"
  revision 2

  head do
    url "https://git.savannah.gnu.org/git/wget.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "xz" => :build
    depends_on "gettext"
  end

  option "with-default-names", "Do not prepend 'l' to the binary"

  depends_on "pkg-config" => :build
  depends_on "pod2man" => :build if MacOS.version <= :snow_leopard
  depends_on "libressl"
  depends_on "libidn2" => :recommended
  depends_on "pcre" => :optional
  depends_on "libmetalink" => :optional
  depends_on "gpgme" => :optional

  def install
    args = %W[
      --prefix=#{prefix}
      --sysconfdir=#{etc}
      --with-ssl=openssl
      --with-libssl-prefix=#{Formula["libressl"].opt_prefix}
      --disable-debug
    ]

    args << "--program-prefix=l" if build.without? "default-names"
    args << "--disable-pcre" if build.without? "pcre"
    args << "--with-metalink" if build.with? "libmetalink"
    args << "--with-gpgme-prefix=#{Formula["gpgme"].opt_prefix}" if build.with? "gpgme"

    system "./bootstrap" if build.head?
    system "./configure", *args
    system "make", "install"

    if build.without? "default-names"
      mv info/"wget.info", info/"lwget.info"
      mv man1/"wget.1", man1/"lwget.1"
      rm_rf share/"locale" # Not worth renaming every single file here.
    end
  end

  def caveats
    return if build.with? "default-names"
    <<~EOS
      The binary is prepended with a 'l' so this can be used
      alongside Homebrew's `wget` without conflict.
    EOS
  end

  test do
    system bin/"lwget", "-O", "/dev/null", "https://duckduckgo.com"
  end
end
