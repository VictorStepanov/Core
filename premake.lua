require './Dependencies/premake'

newoption
{
	trigger = "shared",
	description = "Build as shared libraries",
}

newoption
{
	trigger = "rtti",
	description = "Enable run-time type information",
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

	defines
	{
		"HELIUM_HEAP=1",
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

	if _OPTIONS['rtti'] then
		rtti "On"
		defines
		{
			"HELIUM_RTTI=1",
		}
	else
		rtti "Off"
		defines
		{
			"HELIUM_RTTI=0",
		}
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

	defines
	{
		"HELIUM_HEAP=0"
	}

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