from dataclasses import dataclass
import json
from typing import assert_never, Iterable, Self
#from sortedcontainers import SortedList
from rpgxp.util import Comparable, JsonDumpable, Just, Maybe

@dataclass
class Tree[T: Comparable]:
    label: T
    children: Forest

    def __lt__(self, other: Self) -> bool:
        return self.label < other.label

type Forest[T: Comparable] = list[Tree[T]]

@dataclass
class Row[T, U]:
    id_: T
    parent_id: Maybe[T]
    label: U

def from_rows[T, U: Comparable](
    rows: Iterable[Row[T, U]]
) -> Forest:

    result: Forest[U] = []
    id_to_children: dict[T, Forest[U]] = {}

    for row in rows:
        row_id = row.id_
        maybe_parent_id = row.parent_id

        match maybe_parent_id:
            case None:
                sibling_list = result
            case Just(parent_id):
                if parent_id in id_to_children:
                    sibling_list = id_to_children[parent_id]
                else:
                    sibling_list = []
                    id_to_children[parent_id] = sibling_list
            case _:
                assert_never(maybe_parent_id)

        if row_id in id_to_children:
            children_list = id_to_children[row_id]
        else:
            children_list = []
            id_to_children[row_id] = children_list

        sibling_list.append(Tree(row.label, children_list))

    return result

def to_json_dumpable(forest: Forest) -> JsonDumpable:
    return [{
        'label': tree.label,
        'children': to_json_dumpable(tree.children)
    } for tree in forest]

def to_json(forest: Forest) -> str:
    return json.dumps(to_json_dumpable(forest))
