require './Dependencies/premake'

newoption
{
	trigger = "shared",
	description = "Build as shared libraries",
}

newoption
{
	trigger = "nortti",
	description = "Disable run-time type information",
}

-- Common settings for projects linking with libraries.
Helium.DoBasicProjectSettings = function()

	configuration {}

	language "C++"

	floatingpoint "Fast"

	flags
	{
		"FatalWarnings",
	}

	if _OPTIONS['shared'] then
		defines
		{
			"HELIUM_SHARED=1",
		}
	else
		defines
		{
			"HELIUM_SHARED=0",
		}
	end

	if _OPTIONS['nortti'] then
		rtti "Off"
	end

	includedirs
	{
		"Source",
		"Dependencies",
	}

	configuration { "windows", "SharedLib or *App" }
		links
		{
			"dbghelp",
			"ws2_32",
			"wininet",
		}

	configuration "macosx or linux"
		buildoptions
		{
			"-std=c++11",
		}

	configuration { "macosx", "SharedLib or *App" }
		linkoptions
		{
			"-stdlib=libc++",
			"-framework CoreFoundation",
			"-framework Carbon",
			"-framework IOKit",
		}

	configuration "linux"
		buildoptions
		{
			"-pthread",
		}

	configuration {}

end

Helium.DoTestsProjectSettings = function()

	configuration {}

	kind "ConsoleApp"

	Helium.DoBasicProjectSettings()

	includedirs
	{
		".",
		"Dependencies/googletest/googletest/include"
	}

	links
	{
		"googletest"
	}

	postbuildcommands
	{
		"\"%{cfg.linktarget.abspath}\""
	}

	configuration "linux"
		links
		{
			"pthread",
			"dl",
			"rt",
			"m",
			"stdc++",
		}

	configuration {}

end

Helium.DoModuleProjectSettings = function( baseDirectory, tokenPrefix, moduleName, moduleNameUpper )

	configuration {}

	defines
	{
		"HELIUM_HEAP=1",
		"HELIUM_MODULE=" .. moduleName
	}

	if os.host() == "windows" then

		local header = "Precompile.h"
		if os.host() == "macosx" then
			header = path.join( moduleName, header )
			header = path.join( baseDirectory, header )
			header = path.join( "..", header )
			header = path.join( "..", header )
		end
		pchheader( header )

		local source = "Precompile.cpp"
		source = path.join( moduleName, source )
		source = path.join( baseDirectory, source )
		pchsource( source )
		
	end

	Helium.DoBasicProjectSettings()

	if _OPTIONS['shared'] then
		kind "SharedLib"
	else
		kind "StaticLib"
	end

	if string.len(tokenPrefix) > 0 then
		tokenPrefix = tokenPrefix .. "_"
	end

	if os.host() == "windows" then
		configuration "SharedLib"
			defines
			{
				tokenPrefix .. moduleNameUpper .. "_EXPORTS",
			}
	end

	if os.host() == "macosx" then
		configuration "SharedLib"
			linkoptions
			{
				"-Wl,-install_name,@executable_path/lib" .. project().name .. ".dylib",
			}
	end

	configuration {}

end
