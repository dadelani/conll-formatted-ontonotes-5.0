import codecs
import sys

import skeleton2conll

def remove_edited_subtree(input_fname, output_fname):
    print('Removing subtrees tagged EDITED from {}'.format(input_fname))

    edited_trees = []

    with codecs.open(input_fname, 'r', 'utf8') as inf:
        for a_tree in skeleton2conll.iterate_trees(inf):
            sexpr = skeleton2conll.parse_sexpr(a_tree)
            change_func = skeleton2conll.transformations['-edited']
            try:
                old_sexpr = sexpr[:]
                sexpr = change_func(sexpr)
            except Exception:
                sys.stderr.write('ERR in Tree:\n{}\n\nInput sexpr:\n{}\n'.format(
                    a_tree, skeleton2conll.pp(sexpr)))
                raise

            edited_trees.append(skeleton2conll.unparse_sexpr(sexpr))

    print('Writing fixed trees to {}'.format(output_fname))

    with codecs.open(output_fname, 'w', 'utf8') as outf:
        for a_tree in edited_trees:
            outf.write(skeleton2conll.pretty_print_tree_string(a_tree) + '\n')

if __name__ == '__main__':
    assert len(sys.argv) == 3
    input_fname, output_fname = sys.argv[1], sys.argv[2]
    remove_edited_subtree(input_fname, output_fname)

