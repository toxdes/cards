"use client";

import { Button } from "@/components/ui/button";
import { Download, Menu, X, Code2 } from "lucide-react";
import Image from "next/image";
import Link from "next/link";
import { useEffect, useState } from "react";

export default function LandingPage() {
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [os, setOS] = useState<string | undefined>(undefined);
  useEffect(() => {
    const getOS = () => {
      if (typeof window === "undefined") return "unknown"; // Prevents errors in SSR
      const navigator = window.navigator;
      const userAgent =
        navigator.userAgent || navigator.vendor || (window as any).opera;
      if (/windows nt/i.test(userAgent)) return "windows";
      if (/android/i.test(userAgent)) return "android";
      if (/macintosh|mac os x/i.test(userAgent)) return "macos";
      if (/iphone|ipad|ipod/i.test(userAgent)) return "ios";
      if (/linux/i.test(userAgent)) return "linux";
      return "unknown";
    };
    if (os === undefined) {
      setOS(getOS());
    }
  }, []);

  const onDownload = () => {
    window.open("https://github.com/toxdes/cards/releases/latest", "_blank");
  };
  const onViewSource = () => {
    window.open("https://github.com/toxdes/cards", "_blank");
  };
  return (
    <div className="min-h-screen bg-[#0A0C10]">
      {/* Navigation */}

      <header className="fixed top-0 left-0 right-0 z-50 bg-[#0A0C10]/80 backdrop-blur-lg border-b border-white/10">
        <div className="container mx-auto px-4">
          <div className="flex items-center justify-between h-16">
            <Link href="/" className="flex items-center">
              <Image src="/icon48.png" alt="logo" width="48" height="48" />
              <span className="font-bold text-white text-2xl mt-1">Cards</span>
            </Link>

            {/* Desktop Navigation */}
            <nav className="hidden md:flex items-center space-x-8">
              <Link
                href="#home"
                className="text-sm text-white hover:text-white transition-colors"
              >
                Home
              </Link>
              <Link
                href="#features"
                className="text-sm text-white hover:text-white transition-colors"
              >
                Features
              </Link>

              <Button
                className="bg-blue-700 hover:bg-blue-800 text-white"
                onClick={onDownload}
              >
                <Download className="mr-2 h-4 w-4" />
                Download Now!
              </Button>
            </nav>

            {/* Mobile Menu Button */}
            <button
              className="md:hidden text-white"
              onClick={() => setIsMenuOpen(!isMenuOpen)}
            >
              {isMenuOpen ? (
                <X className="h-6 w-6" />
              ) : (
                <Menu className="h-6 w-6" />
              )}
            </button>
          </div>

          {/* Mobile Navigation */}
          {isMenuOpen && (
            <div className="md:hidden py-4 border-t border-white/10">
              <nav className="flex flex-col space-y-4">
                <Link
                  href="#home"
                  className="text-sm text-white hover:text-white transition-colors"
                >
                  Home
                </Link>

                <Link
                  href="#features"
                  className="text-sm text-white hover:text-white transition-colors"
                >
                  Features
                </Link>

                <Button
                  className="bg-blue-700 hover:bg-blue-800 text-white w-full"
                  onClick={onDownload}
                >
                  <Download className="mr-2 h-4 w-4" />
                  Download for {os}
                </Button>
              </nav>
            </div>
          )}
        </div>
      </header>

      <main className="pt-16">
        {/* Hero 1 - Quick Find */}
        <section id="home" className="py-20 md:py-32 relative overflow-hidden">
          <div className="container mx-auto px-4">
            <div className="grid md:grid-cols-2 gap-12 items-center">
              <div className="space-y-6">
                <div className="inline-block rounded-full bg-blue-400/10 px-4 py-1.5 text-sm font-medium text-blue-400">
                  Early access
                </div>
                <h2 className="text-4xl md:text-5xl font-bold text-white leading-tight">
                  <Image
                    src="/icon48.png"
                    alt="logo"
                    width="60"
                    height="60"
                    className="inline -mt-4"
                  />
                  Cards - Keep Your Card Details Handy
                </h2>
                <p className="text-md text-white">
                  Okay, calm down! I know it's ironic, and you should never
                  enter sensitive information in random apps, which makes this
                  pretty useless, and you're right.
                </p>
                <p className="text-md text-white">
                  However, it does one thing correctly. It makes managing your
                  credit/debit cards portfolio easier. It helps you retrieve
                  your card information quicker, the card information is
                  literally 2 taps away once you add the card.
                </p>

                <p className="text-md text-white">
                  Consider a not-so-dumb Notes app, tailored for cards. Your
                  data never leaves your device.
                </p>
                <p className="text-xs text-red-400">
                  Caution: This app is for personal use, and assumes user knows
                  what they're doing. Don't use this app if you are a bum.
                </p>
                <div className="flex flex-col space-y-4 md:flex-row md:space-x-4 md:space-y-0">
                  <Button
                    className="bg-blue-700 hover:bg-blue-800 text-white font-weight-600 uppercase w-full"
                    onClick={onDownload}
                    size="lg"
                  >
                    <Download className="mr-2 h-4 w-4 " />
                    Download for {os}
                  </Button>
                  <Button
                    size="lg"
                    variant="outline"
                    className="font-weight-600 uppercase w-full"
                    onClick={onViewSource}
                  >
                    <Code2 className="mr-2 h-4 w-4" />
                    View on Github
                  </Button>
                </div>
              </div>
              <div className="relative">
                <div className="absolute inset-0 bg-gradient-to-r from-yellow-400/20 to-transparent rounded-2xl blur-3xl -z-10" />
                <Image
                  src="https://hebbkx1anhila5yf.public.blob.vercel-storage.com/cards-RpRJmrH1Jzq3UGe0Jnqo33GIVHgWpi.png"
                  alt="Quick card access interface"
                  width={600}
                  height={400}
                  className="rounded-2xl shadow-2xl"
                />
              </div>
            </div>
          </div>
        </section>

        {/* Hero 1 - Quick Find */}
        <section
          id="features"
          className="py-20 md:py-32 relative overflow-hidden"
        >
          <div className="container mx-auto px-4">
            <div className="grid md:grid-cols-2 gap-12 items-center">
              <div className="space-y-6">
                <div className="inline-block rounded-full bg-yellow-400/10 px-4 py-1.5 text-sm font-medium text-yellow-400">
                  Quick Access
                </div>
                <h2 className="text-4xl md:text-5xl font-bold text-white leading-tight">
                  Quickly find your cards, just like a virtual pocket
                </h2>
                <p className="text-md text-white">
                  Access all your saved cards instantly with our intuitive
                  interface. No more fumbling through physical cards.
                </p>
              </div>
              <div className="relative">
                <div className="absolute inset-0 bg-gradient-to-r from-yellow-400/20 to-transparent rounded-2xl blur-3xl -z-10" />
                <Image
                  src="https://hebbkx1anhila5yf.public.blob.vercel-storage.com/cards-RpRJmrH1Jzq3UGe0Jnqo33GIVHgWpi.png"
                  alt="Quick card access interface"
                  width={600}
                  height={400}
                  className="rounded-2xl shadow-2xl"
                />
              </div>
            </div>
          </div>
          global
        </section>

        {/* Hero 2 - Offline Security */}
        <section
          id="security"
          className="py-20 md:py-32 relative overflow-hidden bg-black/30"
        >
          <div className="container mx-auto px-4">
            <div className="grid md:grid-cols-2 gap-12 items-center">
              <div className="relative order-2 md:order-1">
                <div className="absolute inset-0 bg-gradient-to-r from-orange-400/20 to-transparent rounded-2xl blur-3xl -z-10" />
                <Image
                  src="https://hebbkx1anhila5yf.public.blob.vercel-storage.com/cards-RpRJmrH1Jzq3UGe0Jnqo33GIVHgWpi.png"
                  alt="Offline security features"
                  width={600}
                  height={400}
                  className="rounded-2xl shadow-2xl"
                />
              </div>
              <div className="space-y-6 order-1 md:order-2">
                <div className="inline-block rounded-full bg-orange-400/10 px-4 py-1.5 text-sm font-medium text-orange-400">
                  Offline Only
                </div>
                <h2 className="text-4xl md:text-5xl font-bold text-white leading-tight">
                  OFFLINE! Your cards stay with you, secure.
                </h2>
                <p className="text-md text-white">
                  Your card data never leaves your device. Experience complete
                  privacy with our offline-first approach.
                </p>
              </div>
            </div>
          </div>
        </section>

        {/* Hero 3 - Easy Addition */}
        <section className="py-20 md:py-32 relative overflow-hidden">
          <div className="container mx-auto px-4">
            <div className="grid md:grid-cols-2 gap-12 items-center">
              <div className="space-y-6">
                <div className="inline-block rounded-full bg-teal-400/10 px-4 py-1.5 text-sm font-medium text-teal-400">
                  Convenient
                </div>
                <h2 className="text-4xl md:text-5xl font-bold text-white leading-tight">
                  Quickly add a card once, save it FOREVER!
                </h2>
                <p className="text-md text-white">
                  Adding new cards is a breeze. Our smart form automatically
                  formats and validates card details as you type.
                </p>
              </div>
              <div className="relative">
                <div className="absolute inset-0 bg-gradient-to-r from-teal-400/20 to-transparent rounded-2xl blur-3xl -z-10" />
                <Image
                  src="https://hebbkx1anhila5yf.public.blob.vercel-storage.com/cards-RpRJmrH1Jzq3UGe0Jnqo33GIVHgWpi.png"
                  alt="Add new card interface"
                  width={600}
                  height={400}
                  className="rounded-2xl shadow-2xl"
                />
              </div>
            </div>
          </div>
        </section>

        {/* Hero 4 - Backup */}
        <section
          id="backup"
          className="py-20 md:py-32 relative overflow-hidden bg-black/30"
        >
          <div className="container mx-auto px-4">
            <div className="grid md:grid-cols-2 gap-12 items-center">
              <div className="relative order-2 md:order-1">
                <div className="absolute inset-0 bg-gradient-to-r from-green-400/20 to-transparent rounded-2xl blur-3xl -z-10" />
                <Image
                  src="https://hebbkx1anhila5yf.public.blob.vercel-storage.com/cards-RpRJmrH1Jzq3UGe0Jnqo33GIVHgWpi.png"
                  alt="Backup and restore interface"
                  width={600}
                  height={400}
                  className="rounded-2xl shadow-2xl"
                />
              </div>
              <div className="space-y-6 order-1 md:order-2">
                <div className="inline-block rounded-full bg-green-400/10 px-4 py-1.5 text-sm font-medium text-green-400">
                  Encrypted Backup
                </div>
                <h2 className="text-4xl md:text-5xl font-bold text-white leading-tight">
                  Backup your cards, and restore it wherever you like
                </h2>
                <p className="text-md text-white">
                  Never lose your card data with encrypted backups. Restore your
                  cards on any device, securely.
                </p>
              </div>
            </div>
          </div>
        </section>
      </main>

      {/* Footer */}
      <footer className="border-t border-white/10 py-4">
        <div className="container mx-auto px-4">
          <div className="flex flex-col md:flex-row justify-between items-center">
            <div className="flex items-center space-x-2 mb-4 md:mb-0">
              <Image src="/icon48.png" alt="logo" width="48" height="48" />
              <span className="text-white font-bold text-2xl mt-1">Cards</span>
            </div>
            <p className="text-sm text-white/50">
              © {new Date().getFullYear()} txds.me | All rights reserved.
            </p>
          </div>
        </div>
      </footer>
    </div>
  );
}
