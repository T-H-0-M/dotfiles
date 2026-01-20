local luasnip = require("luasnip")
local s = luasnip.snippet
local sn = luasnip.snippet_node
local i = luasnip.insert_node
local d = luasnip.dynamic_node

local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep

local function buffer_filename_base()
	return vim.fn.expand("%:t:r")
end

local function strip_suffix(str, suffix)
	if str:sub(-#suffix) == suffix then
		return str:sub(1, #str - #suffix)
	end
	return str
end

local function lower_first(str)
	if str == nil or str == "" then
		return ""
	end
	return str:sub(1, 1):lower() .. str:sub(2)
end

local function pascal_to_separator(str, sep)
	local value = str:gsub("(%u+)(%u%l)", "%1" .. sep .. "%2")
	value = value:gsub("(%l)(%u)", "%1" .. sep .. "%2")
	return value:lower()
end

local function kebab_case(str)
	return pascal_to_separator(str, "-")
end

local function snake_case(str)
	return pascal_to_separator(str, "_")
end

local function java_package_from_path(path)
	local main_match = path:match(".*/src/main/java/(.+)/[^/]+%.java$")
	if main_match then
		return main_match:gsub("/", ".")
	end

	local test_match = path:match(".*/src/test/java/(.+)/[^/]+%.java$")
	if test_match then
		return test_match:gsub("/", ".")
	end

	return ""
end

local function default_package()
	local pkg = java_package_from_path(vim.fn.expand("%:p"))
	if pkg == "" then
		return "com.example"
	end
	return pkg
end

local function default_class_name(fallback)
	local name = buffer_filename_base()
	if name == "" then
		return fallback
	end
	return name
end

local function pkg_node()
	return sn(nil, i(1, default_package()))
end

local function class_name_node(fallback)
	return function()
		return sn(nil, i(1, default_class_name(fallback)))
	end
end

local function var_from_type(args)
	local type_name = args[1][1] or ""
	type_name = type_name:gsub("<.*>", "")

	local var = lower_first(type_name)
	if var == "" then
		var = "dep"
	end

	return sn(nil, i(1, var))
end

local function controller_base_path_from_class(args)
	local class_name = args[1][1] or ""
	local base = strip_suffix(class_name, "Controller")
	if base == "" then
		base = class_name
	end
	return sn(nil, i(1, "/api/" .. kebab_case(base)))
end

local function controller_service_type_from_class(args)
	local class_name = args[1][1] or ""
	local base = strip_suffix(class_name, "Controller")
	if base == "" then
		base = class_name
	end
	return sn(nil, i(1, base .. "Service"))
end

local function entity_table_name_from_class(args)
	local class_name = args[1][1] or ""
	local base = strip_suffix(class_name, "Entity")
	if base == "" then
		base = class_name
	end
	return sn(nil, i(1, snake_case(base)))
end

local function repo_entity_type_from_repo(args)
	local repo_name = args[1][1] or ""
	local base = strip_suffix(repo_name, "Repository")
	if base == "" then
		base = repo_name
	end
	if base == "" then
		base = "Entity"
	end
	return sn(nil, i(1, base))
end

local function test_subject_type_from_test_class(args)
	local test_class_name = args[1][1] or ""
	local base = strip_suffix(test_class_name, "Test")
	if base == "" then
		base = "Subject"
	end
	return sn(nil, i(1, base))
end

local snippets = {
	s(
		{ trig = "spsvc", name = "Spring Service", dscr = "@Service class (constructor injection)" },
		fmta(
			[[
package <pkg>;

import org.springframework.stereotype.Service;

@Service
public class <ClassName> {

    private final <DepType> <depVar>;

    public <ClassNameRep>(<DepTypeRep> <depVarRep>) {
        this.<depVarRep> = <depVarRep>;
    }

    <finish>
}
]],
			{
				pkg = d(1, pkg_node, {}),
				ClassName = d(2, class_name_node("MyService"), {}),
				ClassNameRep = rep(2),
				DepType = i(3, "Dependency"),
				DepTypeRep = rep(3),
				depVar = d(4, var_from_type, { 3 }),
				depVarRep = rep(4),
				finish = i(0),
			}
		)
	),

	s(
		{
			trig = "spctrl",
			name = "Spring RestController",
			dscr = "@RestController skeleton (constructor injection)",
		},
		fmta(
			[[
package <pkg>;

import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("<basePath>")
public class <ClassName> {

    private final <ServiceType> <serviceVar>;

    public <ClassNameRep>(<ServiceTypeRep> <serviceVarRep>) {
        this.<serviceVarRep> = <serviceVarRep>;
    }

    <finish>
}
]],
			{
				pkg = d(1, pkg_node, {}),
				ClassName = d(2, class_name_node("MyController"), {}),
				ClassNameRep = rep(2),
				basePath = d(3, controller_base_path_from_class, { 2 }),
				ServiceType = d(4, controller_service_type_from_class, { 2 }),
				ServiceTypeRep = rep(4),
				serviceVar = d(5, var_from_type, { 4 }),
				serviceVarRep = rep(5),
				finish = i(0),
			}
		)
	),

	s(
		{ trig = "spdto", name = "Spring DTO (record)", dscr = "Record DTO skeleton" },
		fmta(
			[[
package <pkg>;

public record <DtoName>(
    <components>
) {
    <finish>
}
]],
			{
				pkg = d(1, pkg_node, {}),
				DtoName = d(2, class_name_node("MyDto"), {}),
				components = i(3, "String id"),
				finish = i(0),
			}
		)
	),

	s(
		{ trig = "spent", name = "JPA Entity", dscr = "JPA @Entity skeleton (jakarta.persistence)" },
		fmta(
			[[
package <pkg>;

import jakarta.persistence.*;

@Entity
@Table(name = "<tableName>")
public class <EntityName> {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    <finish>
}
]],
			{
				pkg = d(1, pkg_node, {}),
				EntityName = d(2, class_name_node("MyEntity"), {}),
				tableName = d(3, entity_table_name_from_class, { 2 }),
				finish = i(0),
			}
		)
	),

	s(
		{ trig = "sprepo", name = "Spring Repository", dscr = "Spring Data JPA repository interface" },
		fmt(
			[[
package {pkg};

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface {RepoName} extends JpaRepository<{EntityType}, {IdType}> {{
    {finish}
}}
]],
			{
				pkg = d(1, pkg_node, {}),
				RepoName = d(2, class_name_node("MyRepository"), {}),
				EntityType = d(3, repo_entity_type_from_repo, { 2 }),
				IdType = i(4, "Long"),
				finish = i(0),
			}
		)
	),

	s(
		{ trig = "jclass", name = "Java Class", dscr = "Plain Java class skeleton" },
		fmta(
			[[
package <pkg>;

public class <ClassName> {

    public <ClassNameRep>() {
    }

    <finish>
}
]],
			{
				pkg = d(1, pkg_node, {}),
				ClassName = d(2, class_name_node("MyClass"), {}),
				ClassNameRep = rep(2),
				finish = i(0),
			}
		)
	),

	s(
		{ trig = "jtest", name = "JUnit Test", dscr = "JUnit 5 test class skeleton" },
		fmta(
			[[
package <pkg>;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertNotNull;

class <TestClassName> {

    private <SubjectType> <subjectVar>;

    @BeforeEach
    void setUp() {
        <subjectVarRep> = new <SubjectTypeRep>();
    }

    @Test
    void constructs() {
        assertNotNull(<subjectVarRep2>);
    }
}
]],
			{
				pkg = d(1, pkg_node, {}),
				TestClassName = d(2, class_name_node("MyClassTest"), {}),
				SubjectType = d(3, test_subject_type_from_test_class, { 2 }),
				SubjectTypeRep = rep(3),
				subjectVar = d(4, var_from_type, { 3 }),
				subjectVarRep = rep(4),
				subjectVarRep2 = rep(4),
			}
		)
	),
}

return snippets, {}
