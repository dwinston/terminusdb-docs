:- module(api_init, [
              bootstrap_files/0,
              initialize_database/2,
              initialize_database_with_store/2
          ]).

:- use_module(core(triple)).
:- use_module(core(util)).
:- use_module(core(document)).
:- use_module(core(query), [expand/2, default_prefixes/1]).
:- use_module(core(transaction), [open_descriptor/2]).

:- use_module(library(semweb/turtle)).
:- use_module(library(terminus_store)).
:- use_module(library(http/json)).

/**
 * create_graph_from_turtle(DB:database, Graph_ID:graph_identifier, Turtle:string) is det.
 *
 * Reads in Turtle String and writes initial database.
 */
create_graph_from_turtle(Store, Graph_ID, TTL_Path) :-
    safe_create_named_graph(Store,Graph_ID,Graph_Obj),
    open_write(Store, Builder),

    % write to a temporary builder.
    rdf_process_turtle(
        TTL_Path,
        {Builder}/
        [Triples,_Resource]>>(
            forall(member(T, Triples),
                   (   normalise_triple(T, rdf(X,P,Y)),
                       object_storage(Y,S),
                       nb_add_triple(Builder, X, P, S)))),
        []),
    % commit this builder to a temporary layer to perform a diff.
    nb_commit(Builder,Layer),
    nb_set_head(Graph_Obj, Layer).

:- dynamic template_system_instance/1.
:- dynamic system_schema/1.
:- dynamic repo_schema/1.
:- dynamic layer_schema/1.
:- dynamic ref_schema/1.
bootstrap_files :-
    template_system_instance_json(InstancePath),
    file_to_predicate(InstancePath, template_system_instance),
    system_schema_json(SchemaPath),
    file_to_predicate(SchemaPath, system_schema),
    repository_schema_json(RepoPath),
    file_to_predicate(RepoPath, repo_schema),
    ref_schema_json(RefSchemaPath),
    file_to_predicate(RefSchemaPath, ref_schema),
    woql_schema_json(WOQLSchemaPath),
    file_to_predicate(WOQLSchemaPath, woql_schema).

template_system_instance_json(Path) :-
    once(expand_file_search_path(ontology('system_instance_template.json'), Path)).

system_schema_json(Path) :-
    once(expand_file_search_path(ontology('system_schema.json'), Path)).

repository_schema_json(Path) :-
    once(expand_file_search_path(ontology('repository.json'), Path)).

ref_schema_json(Path) :-
    once(expand_file_search_path(ontology('ref.json'), Path)).

woql_schema_json(Path) :-
    once(expand_file_search_path(ontology('woql.json'), Path)).

config_path(Path) :-
    once(expand_file_search_path(config('terminus_config.pl'), Path)).

initialize_database(Key,Force) :-
    db_path(DB_Path),
    initialize_database_with_path(Key, DB_Path, Force).

storage_version_path(DB_Path,Path) :-
    atomic_list_concat([DB_Path,'/STORAGE_VERSION'],Path).

/*
 * initialize_database_with_path(Key,DB_Path,Force) is det+error.
 *
 * initialize the database unless it already exists or Force is false.
 */
initialize_database_with_path(_, DB_Path, false) :-
    storage_version_path(DB_Path, Version),
    exists_file(Version),
    throw(error(storage_already_exists(DB_Path),_)).
initialize_database_with_path(Key, DB_Path, _) :-
    make_directory_path(DB_Path),
    delete_directory_contents(DB_Path),
    initialize_storage_version(DB_Path),
    open_directory_store(DB_Path, Store),
    initialize_database_with_store(Key, Store).

initialize_storage_version(DB_Path) :-
    storage_version_path(DB_Path,Path),
    open(Path, write, FileStream),
    writeq(FileStream, 1),
    close(FileStream).

initialize_schema_graph(Simple_Graph_Name, Store, Graph_Name, Graph_String, Force, Layer) :-
    (   Force = true
    ->  ignore(safe_delete_named_graph(Store, Graph_Name))
    ;   safe_named_graph_exists(Store, Graph_Name)
    ->  throw(error(schema_graph_already_exists(Simple_Graph_Name), _))
    ;   true),

    open_string(Graph_String, Graph_Stream),
    create_graph_from_json(Store, Graph_Name, Graph_Stream, schema, Layer).

initialize_system_schema(Store, Force, Layer) :-
    system_schema_name(Schema_Name),
    system_schema(System_Schema_String),
    initialize_schema_graph(system, Store, Schema_Name, System_Schema_String, Force, Layer).

initialize_ref_schema(Store, Force) :-
    ref_ontology(Ref_Name),
    ref_schema(Ref_Schema_String),
    initialize_schema_graph(ref, Store, Ref_Name, Ref_Schema_String, Force, _).

initialize_repo_schema(Store, Force) :-
    repository_ontology(Repo_Name),
    repo_schema(Repo_Schema_String),
    initialize_schema_graph(repo, Store, Repo_Name, Repo_Schema_String, Force, _).

initialize_woql_schema(Store, Force) :-
    woql_ontology(WOQL_Name),
    woql_schema(WOQL_Schema_String),
    initialize_schema_graph(woql, Store, WOQL_Name, WOQL_Schema_String, Force, _).

initialize_system_instance(Store, Schema_Layer, Key, Force) :-
    system_instance_name(Instance_Name),
    (   Force = true
    ->  safe_delete_named_graph(Store, Instance_Name)
    ;   safe_named_graph_exists(Store, Instance_Name)
    ->  throw(error(instance_graph_already_exists(system), _))
    ;   true),

    Descriptor = layer_descriptor{ schema: Schema_Layer, variety: system_descriptor},
    open_descriptor(Descriptor, Transaction_Object),

    template_system_instance(Template_Instance_String),
    crypto_password_hash(Key,Hash, [cost(15)]),
    format(string(Instance_String), Template_Instance_String, [Hash]),
    open_string(Instance_String, Instance_Stream),
    create_graph_from_json(Store,Instance_Name,Instance_Stream,
                           instance(Transaction_Object),_).

initialize_database_with_store(Key, Store) :-
    initialize_database_with_store(Key, Store, false).
initialize_database_with_store(Key, Store, Force) :-
    initialize_system_schema(Store, Force, System_Schema),
    initialize_ref_schema(Store, Force),
    initialize_repo_schema(Store, Force),
    initialize_woql_schema(Store, Force),

    initialize_system_instance(Store, System_Schema, Key, Force).
